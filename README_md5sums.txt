### THIS IS A TEMPORARY TOOL WITH LIMITED FUNCTIONALITY ###

To install enter:
$ source <path/to/md5sums.sh>
  # this is temporary and will only be sourced for the current shell

To hash files enter:
$ md5sums <head directory, ie '.'>
  # this will store the md5 hash of every file under the provided directory
  # will likely hang in some sub-dirs of /sys/ if run from root (/)

To check for updated/changed hashes enter:
$ md5sums -c <path/to/checksum/file>
  # run this from the directory that the checksum file is stored in
  # default name for the checksum file is 'checksums.sh', and it is stored
  # -in the location the function is called from
