#!/usr/bin/env bash

# Variables
hostname="$1"

printusage() {
  echo "Usage: sudo ./remove_ctfd_instance.sh <hostname>"
}

echo "$0: Started..."

if [ "$#" -ne 1 ]; then
  echo "Failed: Wrong number of parameters."
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
if [ ! -d "$hostname" ]; then 
  echo "Failed: hostname does not exist."
  exit
fi



echo "Removing nginx proxy..."
rm /etc/nginx/sites-available/"$hostname"
rm /etc/nginx/sites-enabled/"$hostname"

# Restart nginx
systemctl restart nginx



echo "Removing CTFd..."

# Stop CTFd
uwsgi --stop /tmp/ctfd_"$hostname".pid

# Remove CTFd
rm -rf $hostname



echo "$0: Completed successfully!"