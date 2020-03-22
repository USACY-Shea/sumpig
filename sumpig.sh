function sumpig {
  local HELP_STR="Usage: sumpig [OPTIONS] dir" #TODO: fill options
  # if no args provided
  if [[ $# -lt 1 ]]; then  #TODO: two params exp.
    echo -e "$HELP_STR\nAt least one parameter is expected" >&2
  else
    # INIT VARS
    local MODE=-1   # 0          1
    local HASH_NAME=("md5"      "sha256")
    local HASH_FUNC=("md5sum"   "sha256sum")
    local OPTIONS=""
    local CHECK=""
    local FILE=""
    local SUM_PATHS=()
    local IGN_PATHS=()
    local VERBOSE=0
    local DEBUG=false


    #TODO: add "long opts", esp for md5/sha256 (swap for "-m md5")


    # GET ARGS
    #TODO: add mutex option logic (c||f/s/i)
    OPTIND=1
    while getopts 'hm:o:f:s:i:vqc:#' OPTION; do  # getopts is util-linux specific
        case "$OPTION" in
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
          if [[ "$OPTIONS" != "" ]]; then
            echo -e "$HELP_STR\nPass options as a single string enclosed in" \
              "\"quotes\"\nex: [-o \"-a -b '12 3'\"]  -OR-  [-o '-a -b \"12 3\"']" >&2
            return 1
          fi
          OPTIONS="$OPTARG"
          ;;
        f)  # output filepath
          #TODO: store "### DO NOT EDIT OR REMOVE THESE LINES ###" at head of file
          #TODO: store $HASH_NAME[$MODE], SUM_PATHS, IGN_PATHS at head of file
          FILE="$(realpath $OPTARG)"
          ;;
        s)  # add target dir/file (multiple)  #TODO: how to add multiple OPTARGs
          SUM_PATHS+=("$(realpath $OPTARG)")
          ;;
        i)  # add ignore dir/file (multiple)
          IGN_PATHS+=("$(realpath $OPTARG)")
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
        \#) # debug mode
          DEBUG=true
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

    # DEBUG MODE
    if [[ $DEBUG = true ]]; then
      echo "MODE:     $MODE (${HASH_NAME[$MODE]})" >&2
      echo "OPTIONS:  $OPTIONS" >&2
      echo "CHECK:    $CHECK" >&2
      echo "FILE:     $FILE" >&2
      echo "SUM_PATHS: ${SUM_PATHS[@]}" >&2
      echo "IGN_PATHS: ${IGN_PATHS[@]}" >&2
      echo "VERBOSE:  $VERBOSE" >&2
    fi

    #TODO:
    #if [[ "$CHECK" -ne "" ]]; then
      #if [[ MODE -eq -1 ]]; then
        #try to select mode from file header
      #SUM_PATHS=()
      #select DIRS from header
      #IGN_PATHS=()
      #select DIRS from header

    # if [[ $MODE -eq -1 ]]; error out "must select a mode" print all (or default md5??)

    # VALIDATE SUM_PATHS/IGN_PATHS/safefile dir $(basedir FILE)
      #TODO: default current dir if SUM_PATHS is empty

    # MAIN CHECKSUM ROUTINE


      # CHECK/COMPARE HASHES


      # HASH FILES & STORE


  fi
}

function sumpiggy {
  local HELP_STR="Usage: sumpig [OPTIONS] dir" #TODO: fill options
  if [ "$#" -lt 1 ]; then
    echo -e "At least one parameter is expected\n$HELP_STR"
  elif [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo -e $HELP_STR
  else
    # INIT VARS
    #local CURRENT_DIR="$(pwd)"
    local OUTPUT=""
    local SUM_TYPE="md5"
    local SUM_FUNC="md5sum"
    local CHECK=false
    local OPTIONS=""

    # GET ARGS
    #TODO: argparse
    while [[ $# > 1 ]]; do
      local key="$1"
      case $key in
        -h|--help)
          echo -e $HELP_STR
          return 0  # exit function if -h used
          ;;
        --md5|--md5sum)
          SUM_TYPE="md5"
          SUM_FUNC="md5sum"
          ;;
        --sha256|--sha256sum)
          SUM_TYPE="sha256"
          SUM_FUNC="sha256sum"
          ;;
        -c|--check)
          CHECK=true
          ;;
        -o|--output)
          # next arg is output filepath
          # also for non-standard path in sum checks
          OUTPUT=$2
          shift
          ;;
        *)
          OPTIONS="$OPTIONS $1"
          ;;
      esac
      shift
    done
    #TODO: make absolute
    local DIR=$1  # head directory for HashTree

    if [ "$OUTPUT" = "" ]; then
      OUTPUT="$(pwd)/$SUM_TYPE.sumpig"
    fi

    # MAIN CHECKSUM CALL
    # note: option structure for sum functions must be identical to work
    if [ -d "$DIR" ]; then  # if $DIR directory exists
      cd $DIR  # change to head directory
      if [ "$CHECK" = true ]; then  # if -c or --check option specified
        # CHECK/COMPARE SUMS
        $SUM_FUNC --check $OPTIONS $OUTPUT  # check MD5 sums in $OUTPUT file
      else
        # HASH FILES & STORE
        # calculate hash for files in current dir & subdirs excl. $OUTPUT file
        # save result in $OUTPUT file
        echo -e "DBG1"
        find . -type f ! -path "$OUTPUT" -exec $SUM_FUNC $OPTIONS {} + > $OUTPUT
      fi
      cd - > /dev/null  # change to previous directory
    else
      cd $DIR  # if $DIR doesn't exists, cd to generate localized error message
    fi
  fi
}
