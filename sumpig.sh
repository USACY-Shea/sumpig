function sumpig {
  local HELP_STR="Usage: sumpig [OPTIONS] dir" #TODO: fill options
  # if no args provided
  if [[ $# -lt 1 ]]; then  #TODO: two params exp.
    echo -e "At least one parameter is expected\n$HELP_STR" >&2
  else
    # INIT VARS
    #TODO: dict of hash/functions
    local MODE=-1   # 0          1
    local HASH_NAME=("md5"      "sha256")
    local HASH_FUNC=("md5sum"   "sha256sum")
    local CHECK=""
    local FILE=""
    local SUM_DIRS=()
    local IGN_DIRS=()
    local VERBOSE=0
    local DEBUG=false


    # GET ARGS
    OPTIND=1
    while getopts 'hm:12o:s:i:vqc:#' OPTION; do  # getopts is util-linux specific
        case "$OPTION" in
        h)  # help
          echo -e $HELP_STR >&2
          return 0
          ;;
        m)  # hash mode
          #TODO: '-m' for 'mode' with OPTARG and check if in $HASH_NAME
          #      set MODE to index of value in $HASH_NAME
          #      print all from $HASH_NAME on error and exit
          # if MODE -ne -1 error, "only one mode at a time" print all
          # only used once (if [[ IDX -ne -1 ]]
          ;;
        1)  # (TODO:remove) md5 mode
          MODE=0
          ;;
        2)  # (TODO:remove) sha256 mode
          MODE=1
          ;;
        o)  # output filepath  #TODO: change flag? less common use
          #TODO: store SUM_DIRS, IGN_DIRS, MODE at head of file
          FILE="$(realpath $OPTARG)"
          ;;
        s)  # add tree head dir/file (multiple)
          SUM_DIRS+=("$(realpath $OPTARG)")
          ;;
        i)  # add ignore dir/file (multiple)
          IGN_DIRS+=("$(realpath $OPTARG)")
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
        :)
          echo -e "$HELP_STR\nOption requires argument: -$OPTARG" >&2
          return 1
          ;;
        \?)
          echo -e "$HELP_STR\nInvalid option: -$OPTARG" >&2
          return 1
          ;;
        esac
    done

    # DEBUG MODE
    if [[ $DEBUG = true ]]; then
      echo "MODE:     $MODE" >&2
      echo "CHECK:    $CHECK" >&2
      echo "FILE:     $FILE" >&2
      echo "SUM_DIRS: ${SUM_DIRS[@]}" >&2
      echo "IGN_DIRS: ${IGN_DIRS[@]}" >&2
      echo "VERBOSE:  $VERBOSE" >&2
    fi

    #TODO:
    #if [[ "$CHECK" -ne "" ]]; then
      #[[ MODE -eq -1 ]]; then
        #try to select mode from file header
      #SUM_DIRS=()
      #select DIRS from header
      #IGN_DIRS=()
      #select DIRS from header

    # if [[ $MODE -eq -1 ]]; error out "must select a mode" print all

    # VALIDATE SUM_DIRS/IGN_DIRS/safefile dir $(basedir FILE)
      #TODO: default current dir if SUM_DIRS is empty

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
