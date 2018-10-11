#!/usr/bin/env bash

# Default IP address for host
server_ip="10.64.0.19"
server_port="8887"

printusage() {
  echo "sudo $0 <hostname> [--install-root-ca]"
}

if (( $# < 1 )); then
  echo "Failed: Wrong number of arguments."
  printusage
  exit
fi

if [ "$EUID" -ne 0 ]; then 
  echo "Failed: Please run as root."
  printusage
  exit
fi



# Get the DIR of this file
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

# Get the last argument
for last in "$@"; do :; done

# Add hostname to /etc/hosts
source "$DIR/modify_hosts.sh" add "$server_ip" "$hostname"

# Install root CA if option is set in last argument
remove_last_arg=0
if [ "$last" == "--install-root-ca" ]; then 
  source "$DIR/install_root_ca.sh"
  remove_last_arg=1
fi