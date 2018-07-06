# ctfd
Repository for CTFd deployment in NCL

## ctfd_instance_manager.py

Handles the creation, deletion, starting and stopping of CTFd instances on CTFd server VM.

Listens to **socket 0.0.0.0:8887** for commands, then calls the corresponding scripts in Deployment_Scripts.

This program should always be running as a background service, otherwise all CTFd instances will be stopped.

### Running this server program

#### Prerequisites

1. Install the requirements on your machine using `sudo Deployment_Scripts/install_ctfd_prerequisites.sh`

#### To start as a background service

1. Create a file `/lib/systemd/system/ctfd-instance-manager.service` with the following content

```
[Unit]
Description=CTFd Instance Manager
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
ExecStart=/usr/bin/env python /opt/ctfd-deployment/ctfd_instance_manager.py

[Install]
WantedBy=multi-user.target
```

where */opt/ctfd-deployment/ctfd_instance_manager.py* is your actual file path.

2. Start the service by typing into a terminal `sudo systemctl start ctfd-instance-manager`

3. Enable the service to automatically start on boot `sudo systemctl enable ctfd-instance-manager`

> Note: It may take a few minutes for the server listener to start completely.

#### To stop this program

1. Stop the service by typing into a terminal `sudo systemctl stop ctfd-instance-manager`

2. Disable the service from automatically start on boot `sudo systemctl disable ctfd-instance-manager`

### Client program

Clients can use Netcat or other applications to send commands to this server program.

For example:

> echo 'add cs4238.ctf.ncl.sg "CS4238 CTF" ncl.vte1@gmail.com' | nc 10.64.0.19 8887

### List of accepted commands 

```list```: Lists all existing CTFd instances and their hostnames

```add <hostname> <ctf_name> <admin_ncl_email>```: Adds a new CTFd instance

```start <hostname>```: Starts an existing CTFd instance

```stop <hostname>```: Stops a running CTFd instance

```remove <hostname>```: Removes an existing CTFd instance