#!/usr/bin/env bash

# Variables
hostname="$1"
ctfname="$2"
adminemail="$3"

printusage() {
  echo "Usage: sudo $0 <hostname> <ctf_name> <admin_ncl_email>"
}

echo "$0: Started..."

if [ "$#" -ne 3 ]; then
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

# Fail if there exists another CTFd instance with the same hostname
if [ -d "$hostname" ]; then 
  echo "Failed: hostname already exists."
  exit
fi

echo "Please make sure that you have an active Internet connection."



echo "Creating new nginx proxy..."

# Create new nginx proxy file
cat > /etc/nginx/sites-available/"$hostname" << EOF
server {
    listen 80;
    listen [::]:80;

    server_name $hostname;

    location / { try_files \$uri @uri_$hostname; }
    location @uri_$hostname {
        include uwsgi_params;
        uwsgi_pass unix:/tmp/uwsgi_$hostname.sock;
    }
}
EOF

ln -s /etc/nginx/sites-available/"$hostname" /etc/nginx/sites-enabled/

# Restart nginx
systemctl restart nginx



echo "Setting up CTFd..."

# Clone the CTFd folder
git clone https://github.com/nus-ncl/CTFd.git "$hostname"
cd "$hostname"

# Start this CTFd instance with uWSGI
uwsgi --plugin python -s /tmp/uwsgi_"$hostname".sock -w 'CTFd:create_app()' --chmod-socket=666 --pidfile /tmp/ctfd_"$hostname".pid --pyargv "--ncl-sio-url http://172.18.178.14:8080 --ncl-team-name ncltest01" &>/dev/null &

# Set up CTFd
curl --data "ctf_name=$ctfname&name=$adminemail&email=$adminemail&password=unused_password" -H "Host: $hostname" http://localhost/setup

# Stop CTFd
uwsgi --stop /tmp/ctfd_"$hostname".pid



echo "$0: Completed successfully!"