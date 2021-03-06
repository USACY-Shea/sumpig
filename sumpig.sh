function __join_by {
  # Use: __join_by $CONNECTOR $A $B $C
  # Ex:  __join_by , A b C  ->  A,b,C
  local IFS="$1"
  shift
  echo "$*"
}


function sumpig {
  local HELP_STR="Usage: sumpig [[-m (md5|sha256)] [[-s PATH]...] [-f PATH]] | [-c PATH] [-o \"OPTIONS\"]" #TODO: fill options
  if [[ $# -lt 1 ]]; then # if no args provided  #TODO: X params expected
    echo -e "$HELP_STR\nAt least one parameter is expected" >&2
    return 1
  fi

  #TODO TODO: fix mangled VARS (_) !!!!!
  # INIT VARS
  local MODE=-1   # 0          1
  local HASH_NAME=("md5"      "sha256")
  local HASH_FUNC=("md5sum"   "sha256sum")
  local OPTIONS=""
  local CHECK=""
  local OUTPUT=""
  local SUM_PATHS=()
  local IGN_PATHS=()
  #TODO: currently unused; use to determine what will print (to stderr)
  local VERBOSE=0
  local DEBUG=false


  #TODO: add "long opts", esp for md5/sha256 (swap for "-m md5")


  # GET ARGS
  #TODO: add mutex option logic (c||f/s/i)
  OPTIND=1
  while getopts 'hm:o:f:s:vqc:#' OPTION; do  # getopts is util-linux specific
    #TODO: add 'i:' back to opts for ignore
    case "$OPTION" in
    \#) # debug mode
      DEBUG=true
      ;;
    h)  # help
      echo -e "$HELP_STR" >&2
      return 0
      ;;
    m)  # hash mode
      if [[ $MODE -ne -1 ]]; then  # duplicate option error
        echo -e "$HELP_STR\nOnly one mode (-m) can be set" >&2
        return 1
      fi
      # find OPTARG in HASH_NAMEs, store index in MODE
      MODE=-1
      for i in "${!HASH_NAME[@]}"; do  # create list of indices
        # cmp val and break if found
        [[ "${HASH_NAME[$i]}" = "$OPTARG" ]] && MODE=$i && break
      done;
      if [[ $MODE -eq -1 ]]; then  # invalid mode error
        echo -e "$HELP_STR\nInvalid hash mode '$OPTARG'\nSelect from: ${HASH_NAME[@]}" >&2
        return 1
      fi
      ;;
    o)  # hash options
      OPTIONS+=" $OPTARG"
      ;;
    f)  # output filepath
      # this option is ignored if '-c' is used
      OUTPUT="$(realpath $OPTARG)"
      ;;
    s)  # add target dir/file (multiple)  #TODO: how to add multiple OPTARGs
      # this option is ignored if '-c' is used
      #TODO: currently can't handle spaces in dirs
      #TODO: test with file endpoints
      SUM_PATHS+=($(realpath $OPTARG))
      ;;
    i)  # add ignore dir/file (multiple)
      # this option is ignored if '-c' is used
      #IGN_PATHS+=("$(realpath $OPTARG)")
      #TODO: try single quotes??
      IGN_PATHS=()  #TODO: doesn't function properly, feature temp. cut
      ;;
    v)  # verbose (multiple)
      if [[ $VERBOSE -ge 0 ]]; then  # skips if '-q' used
        ((++VERBOSE))
      fi
      ;;
    q)  # quiet (overrides verbose)
      ((VERBOSE=-1))
      ;;
    c)  # check hashes
      CHECK="$OPTARG"
      ;;
    :)  # error: missing argument
      echo -e "$HELP_STR\nOption requires argument: -$OPTARG" >&2
      return 1
      ;;
    \?) # error: invalid argument
      echo -e "$HELP_STR\nInvalid option: -$OPTARG" >&2
      return 1
      ;;
    esac
  done

  # DEBUG MODE (show vars)
  if [[ $DEBUG = true ]]; then
    echo "MODE:      $MODE (${HASH_NAME[$MODE]})" >&2
    echo "OPTIONS:   $OPTIONS" >&2
    echo "CHECK:     $CHECK" >&2
    echo "OUTPUT:    $OUTPUT" >&2
    echo "SUM_PATHS: ${SUM_PATHS[@]}" >&2
    echo "IGN_PATHS: ${IGN_PATHS[@]}" >&2
    echo "VERBOSE:   $VERBOSE" >&2
  fi

  # VALIDATE SAVEFILE DIR $(basedir "$OUTPUT")

  #TODO:
  # CHECK ROUTINEMAIN
  if [[ "$CHECK" != "" ]]; then
    # AUTOSELECT HASH MODE
    if [[ $MODE -eq -1 ]]; then
      #echo -e "Trying to determine hash mode from file..." >&2
      #try to select mode from file header
      #if fails print error and exit
      echo -e "$HELP_STR\nSelect a hash mode: ${HASH_NAME[@]}" >&2 #TODO:rm
      return 1 #TODO:rm
    fi
    # CHECK/COMPARE HASHES
    ${HASH_FUNC[$MODE]} --check $OPTIONS $CHECK  # check hashes in $CHECK file

  # HASH ROUTINE
  else
    if [[ $MODE -eq -1 ]]; then
      echo -e "$HELP_STR\nSelect a hash mode: ${HASH_NAME[@]}" >&2
      return 1
    fi

    # VALIDATE SUM_PATHs/IGN_PATHs
      #TODO: default current dir if SUM_PATHS is empty??

    #TODO: set default $OUTPUT

    # HASH FILES & STORE
    # MAIN CHECKSUM CALL
    # note: option structure for sum functions must be identical to work

    #TODO: possibly rm?? assess
    # format IGN_PATHS
    local FMT_IGN_PATHS=()
    for _PATH in ${IGN_PATHS[@]}; do
      FMT_IGN_PATHS+=("! -path \"$_PATH\*\"")
    done

    #TODO: possibly rm?? assess
    # format SUM_PATHS
    local FMT_SUM_PATHS=()
    for _PATH in ${SUM_PATHS[@]}; do
      FMT_SUM_PATHS+=("\"$_PATH\"")
    done

    # DEBUG MODE (show formatted paths)
#    if [[ $DEBUG -eq true ]]; then
#      echo -e "\nIGN_PATHS (formatted):\n${FMT_IGN_PATHS[@]}" >&2
#      echo -e "\nSUM_PATHS (formatted):\n${FMT_SUM_PATHS[@]}" >&2
#    fi

    # add file header
    echo -e "### DO NOT EDIT OR REMOVE THESE LINES ###\n### Hash Type: ${HASH_NAME[$MODE]}\n### Hashed Paths: ${SUM_PATHS[@]}\n### Ignore Paths: ${IGN_PATHS[@]}" > $OUTPUT

    if [[ $DEBUG -eq true ]]; then
      local asdf=0 # echo -e Hash CLI:\nfind $(${FMT_SUM_PATHS[@]}) -type f ! -path "$OUTPUT" ${FMT_IGN_PATHS[@]} -exec ${HASH_FUNC[$MODE]} $OPTIONS {} + \>\> $OUTPUT \n\n
    fi
    # calculate hash and save in $OUTPUT
    find ${SUM_PATHS[@]} -type f ! -path "$OUTPUT" ${FMT_IGN_PATHS[@]} -exec ${HASH_FUNC[$MODE]} $OPTIONS {} + >> $OUTPUT
  fi
}
