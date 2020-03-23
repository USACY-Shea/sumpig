SUMPIG Useage Notes:

Installation (temporary):
  $ source <path/to/sumpig.sh>

Installation (permanent):
  Add a line to your .bashrc or other profile loader file:
    source <path/to/sumpig.sh>
  Re-source .bashrc or open a new shell.

Options:
  -s PATH     Add a directory to sum/hash recursively. Use multiple '-s' options
              for multiple recursive trees in the same hashfile output.

  -m MODE     Select hash mode. Current options are "md5" or "sha256". Only use
              one of this option per run.

  -o OPTIONS  Pass option parameters directly to the hashing function. Put
              quotes around your option string.

  -f PATH     Manually input path for an output file. When not used in 'check'
              mode, this file will be overwritten.

  -c PATH     Check the stored paths and hashes at PATH for any changes in data.

Example use:
  $ sumpig -m sha256 -s /home/user/Documents -s /usr/sbin -f ./hashes.sha256
  $ sumpig -m sha256 -c ./hashes.sha256
