function sumpig {
  local HELP_STR="Usage: sumpig [OPTIONS] dir" #TODO: fill options
  # if no args provided
  if [[ $# -lt 1 ]]; then  #TODO: two params exp.
    echo -e "At least one parameter is expected\n$HELP_STR"
  # if first arg is -h (catches edge case) #TODO: no flagless case, remove?
  elif [[ $1 = "-h" ]] || [[ $1 = "--help" ]]; then
    echo -e $HELP_STR
  else
    # INIT VARS
    #TODO: dict of hash/functions
    local MODE=0    # 0          1
    local HASH_NAME=("md5"      "sha256")
    local HASH_FUNC=("md5sum"   "sha256sum")
    local CHECK=false
    local FILE=""
    local DIRS=()
    local VERBOSE=0


    # GET ARGS
    while getopts "" opt; do  # getopts is util-linux specific
        case "$opt" in
        h|\?)  # help
          show_help
          return 0
          ;;
        m)  # md5 mode
          MODE=0
          ;;
        s)  # sha256 mode
          MODE=1
          ;;
        c)  # check
          CHECK=true
          ;;
        f)  # save filepath (output/check)
          ;;
        d)  # add tree head dir (multiple)
          ;;
        i)  # add ignore dir (multiple)
          ;;
        v)  # verbose (multiple)
          if [[ $VERBOSE -ge 0 ]]; then
            ((++VERBOSE))
          fi
          ;;
        q)  # quiet (overrides verbose)
          ((VERBOSE=-1))
          ;;
        esac
    done

    # VALIDATE DIRS

    # MAIN CHECKSUM ROUTINE


     # CHECK/COMPARE HASHES


     # HASH FILES & STORE


  fi
}

function sumpig {
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
