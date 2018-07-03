#!/usr/bin/env bash

# Variables
hostname="$1"
ctfname="$2"
adminemail="$3"

echo "$0: Started..."

if [ "$#" -ne 3 ]; then
  echo "Failed: Wrong number of parameters."
  exit
fi

if [ "$EUID" -ne 0 ]; then 
  echo "Failed: Please run as root."
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



echo "Starting CTFd..."

# Clone the CTFd folder
git clone https://github.com/nus-ncl/CTFd.git "$hostname"
cd "$hostname"

# Run CTFd with uWSGI
nohup uwsgi --plugin python -s /tmp/uwsgi_"$hostname".sock -w 'CTFd:create_app()' --chmod-socket=666 --pidfile /tmp/ctfd_"$hostname".pid &



echo "Setting up CTFd..."

# POST to CTFd setup page
curl --data "ctf_name=$ctfname&name=$adminemail&email=$adminemail&password=unused_password" http://"$hostname"/setup



echo "$0: Completed successfully!"