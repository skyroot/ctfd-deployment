#!/usr/bin/env bash

printusage() {
  echo "Usage: sudo $0"
}

echo "$0: Started..."

if [ "$EUID" -ne 0 ]; then 
  echo "Failed: Please run as root."
  printusage
  exit
fi

echo "Please make sure that you have an active Internet connection."

# Set current working directory to script folder
cd "${0%/*}"



echo "Setting up uWSGI and nginx..."

# Install uwsgi and nginx
apt-get install uwsgi uwsgi-plugin-python nginx

# Uncomment the line: server_names_hash_bucket_size
sed -i '/#.* server_names_hash_bucket_size /s/#//' /etc/nginx/nginx.conf

# Restart nginx
systemctl restart nginx



echo "Installing CTFd prerequisites..."

# Clone the CTFd folder
git clone https://github.com/nus-ncl/CTFd.git ctfd-temp
cd ctfd-temp

# Install CTFd prerequisites
./prepare.sh

# Delete the CTFd folder
cd ..
rm -rf ctfd-temp



echo "$0: Completed successfully!"