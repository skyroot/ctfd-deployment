# ctfd
Repository for CTFd deployment in NCL

## Client Scripts

### modify_hosts.sh

To add or remove a line in /etc/hosts file to point a hostname to the IP address.

```sudo ./modify_hosts.sh add <ip_address> <hostname>```

Example as DETERLab command for new client nodes:

> tb-set-node-startcmd $n0 "sudo /share/ctfd/modify_hosts.sh add 10.64.0.19 ctf.ncl.sg"

### send_tcp_command.sh

To send a command to the specified server, such as CTFd Instance Manager.

```sudo ./send_tcp_command.sh <server_ip> <server_port> <command> [<command_args...>]```

Example as DETERLab command to add a new CTFd instance:

> tb-set-node-startcmd $n0 "sudo /share/ctfd/send_tcp_command.sh 10.64.0.19 8887 add cs4238.ctf.ncl.sg 'CS4238 CTF' ncl.vte1@gmail.com"

## CTFd Instance Manager + Server Scripts

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

```add <hostname> <ctf_name> <admin_ncl_email> <ncl_team_name>```: Adds a new CTFd instance

- *hostname* can be any URL
- *ctf_name* is the name shown on the CTF website banner
- *admin_ncl_email* is the ncl.sg login email of this CTF's admin
- *ncl_team_name* is the name of the NCL Team whose members are allowed to login

```add-plugin <hostname> <plugin_name>```: Adds the plugin to an existing CTFd instance

Available plugins:

- ctfd-linear-unlocking
- ctfd-challenge-feedback

```start <hostname>```: Starts an existing CTFd instance

```stop <hostname>```: Stops a running CTFd instance

```remove <hostname>```: Removes an existing CTFd instance