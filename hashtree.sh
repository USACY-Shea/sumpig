function hashtree {
  HELP_STR="Usage: hashtree [OPTIONS] dir" #TODO: fill options
  if [ "$#" -lt 1 ]; then
    echo -e "At least one parameter is expected\n$HELP_STR"
  elif [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo -e $HELP_STR
  else
    # INIT VARS
    local OUTPUT=""
    local SUM_TYPE="md5"
    local SUM_FUNC="md5sum"
    local CHECK=false
    local OPTIONS=""

    # GET ARGS
    while [[ $# > 1 ]]; do
      local key="$1"
      case $key in
        -h|--help)
          echo -e $HELP_STR
          break  # exit function if -h used
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
      OUTPUT="$SUM_TYPE_checksums"
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
        find . -type f ! -name "$OUTPUT" -exec $SUM_FUNC $OPTIONS {} + > $OUTPUT
      fi
      cd - > /dev/null  # change to previous directory
    else
      cd $DIR  # if $DIR doesn't exists, cd to generate localized error message
    fi
  fi
}
