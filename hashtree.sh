function hashtree {
  HELP_STR="Usage: hashtree [OPTIONS] dir" #TODO: fill options
  if [ "$#" -lt 1 ]; then
    echo -e "At least one parameter is expected\n$HELP_STR"
  elif [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo -e $HELP_STR
  else
    echo -e $1
    local OUTPUT="checksums.md5" #TODO: after args
    local SUM_TYPE="md5"
    local CHECK=false
    local OPTIONS=""

    while [[ $# > 1 ]]; do
      local key="$1"
      case $key in
        -h|--help)
          echo -e $HELP_STR
          break  # exit function if -h used
          ;;
        -c|--check)
          CHECK=true
          ;;
        -o|--output)
          OUTPUT=$2
          shift
          ;;
        *)
          OPTIONS="$OPTIONS $1"
          ;;
      esac
      shift
    done
    local DIR=$1 

    if [ "$OUTPUT" = "" ]; then
      OUTPUT="$SUM_TYPE_checksums"
    fi

    if [ -d "$DIR" ]; then  # if $DIR directory exists
      cd $DIR  # change to $DIR directory
      if [ "$CHECK" = true ]; then  # if -c or --check option specified
        md5sum --check $OPTIONS $OUTPUT  # check MD5 sums in $OUTPUT file
      else                          # else
        find . -type f ! -name "$OUTPUT" -exec md5sum $OPTIONS {} + > $OUTPUT  # Calculate MD5 sums for files in current directory and subdirectories excluding $OUTPUT file and save result in $OUTPUT file
      fi
      cd - > /dev/null  # change to previous directory
    else
      cd $DIR  # if $DIR doesn't exists, change to it to generate localized error message
    fi
  fi
}
