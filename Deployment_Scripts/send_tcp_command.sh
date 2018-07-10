#!/usr/bin/env bash

# Arguments
server_ip="$2"
server_port="$3"

printusage() {
  echo "sudo $0 <server_ip> <server_port> <command> [<command_args...>]"
}

if (( $# < 3 )); then
  echo "Failed: Wrong number of arguments."
  printusage
  exit
fi



echo "Sending the command..."
echo "${@:3}" | nc $server_ip $server_port



echo "$0: Command sent successfully!"