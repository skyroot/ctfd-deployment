#!/usr/bin/env bash

# Variables
hostname="$1"
plugin_git_url="$2"

printusage() {
  echo "Usage: sudo $0 <hostname> <plugin_git_url>"
}

echo "$0: Started..."

if [ "$#" -ne 2 ]; then
  echo "Failed: Wrong number of arguments."
  printusage
  exit
fi

if [ "$EUID" -ne 0 ]; then 
  echo "Failed: Please run as root."
  printusage
  exit
fi

# Set current working directory to script folder
cd "${0%/*}"

# Fail if this CTFd instance does not exist
if [ ! -d "$hostname/CTFd/plugins" ]; then 
  echo "Failed: hostname does not exist."
  exit
fi

# Set current working directory to plugins folder
cd "$hostname/CTFd/plugins"

echo "Please make sure that you have an active Internet connection."



echo "Adding the plugin..."

# Clone the plugin folder
git clone $plugin_git_url



echo "$0: Completed successfully!"