# ctfd-deployment
Repository for CTFd deployment in NCL

## Client Scripts

### modify_hosts.sh

To add or remove a line in /etc/hosts file to point a hostname to the IP address.

```sudo ./modify_hosts.sh add <ip_address> <hostname>```

### send_tcp_command.sh

To send a command to the specified server, such as CTFd Instance Manager.

```sudo ./send_tcp_command.sh <server_ip> <server_port> <command> [<command_args...>]```

### install_root_ca.sh

Installs root CA into Firefox, Chrome, Chromium, Vivaldy and other browsers on Linux.

```sudo ./install_root_ca.sh```

### setup_ctfd.sh

Wrapper for client scripts to setup CTFd client and server, as there is a max limit of 213 characters in DETERLab startcmd.

```sudo ./setup_ctfd.sh <hostname> '<ctf_name>' <admin_ncl_email> <ncl_team_name> [<plugin_names...>] [--install-root-ca]```

- *hostname* must end with ".ctf.ncl.sg" (e.g. cs4238.ctf.ncl.sg)
- *ctf_name* is the name shown on the CTF website banner
- *admin_ncl_email* is the ncl.sg login email of this CTF's admin
- *ncl_team_name* is the name of the NCL Team whose members are allowed to login
- *plugin_names* is space-separated list of [optional plugins](#available-plugins) to install
- *--install-root-ca* is an optional argument which runs install_root_ca.sh if set

Example as DETERLab command to setup client and server:

> tb-set-node-startcmd $n0 "sudo /share/ctfd/setup_ctfd.sh cs4238.ctf.ncl.sg 'CS4238 CTF' ncl.vte1@gmail.com ncltest01 ctfd-linear-unlocking ctfd-challenge-feedback --install-root-ca"

### setup_ctfd_client.sh

Wrapper for client scripts to setup CTFd client, as there is a max limit of 213 characters in DETERLab startcmd.

```sudo ./setup_ctfd_client.sh <hostname> [--install-root-ca]```

- *hostname* is the hostname of the CTF server (e.g. cs4238.ctf.ncl.sg)
- *--install-root-ca* is an optional argument which runs install_root_ca.sh if set

Example as DETERLab command to setup client only:

> tb-set-node-startcmd $n1 "sudo /share/ctfd/setup_ctfd_client.sh cs4238.ctf.ncl.sg --install-root-ca"

## CTFd Instance Manager + Server Scripts

Handles the creation, deletion, starting and stopping of CTFd instances on CTFd server VM.

Listens to **socket 0.0.0.0:8887** for commands, then calls the corresponding scripts in server_scripts.

This program should always be running as a background service, otherwise all CTFd instances will be stopped.

### Running this server program

#### Prerequisites

1. Install the requirements on your machine using `sudo server_scripts/install_ctfd_prerequisites.sh`

1. Add hostname "localhost.ctf.ncl.sg" to IP address 127.0.0.1 in `/etc/hosts` file.

1. Create self-signed SSL certificate for Nginx by following [this guide](deployment_guide/core/ncl-nginx-root-ca-certificate.txt)

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

#### To stop this program

1. Stop the service by typing into a terminal `sudo systemctl stop ctfd-instance-manager`

2. Disable the service from automatically start on boot `sudo systemctl disable ctfd-instance-manager`

### Client program

Clients can use Netcat or other applications to send commands to this server program.

For example:

> echo 'add cs4238.ctf.ncl.sg "CS4238 CTF" ncl.vte1@gmail.com' | nc 10.64.0.19 8887

### List of accepted commands 

```list```: Lists all existing CTFd instances and their hostnames

```add <hostname> "<ctf_name>" <admin_ncl_email> <ncl_team_name>```: Adds a new CTFd instance

- *hostname* must end with ".ctf.ncl.sg" (e.g. cs4238.ctf.ncl.sg)
- *ctf_name* is the name shown on the CTF website banner
- *admin_ncl_email* is the ncl.sg login email of this CTF's admin
- *ncl_team_name* is the name of the NCL Team whose members are allowed to login

```add-plugin <hostname> <plugin_name>```: Adds the plugin to an existing CTFd instance

#### Available plugins:

- ctfd-linear-unlocking
- ctfd-challenge-feedback

```start <hostname>```: Starts an existing CTFd instance

```stop <hostname>```: Stops a running CTFd instance

```remove <hostname>```: Removes an existing CTFd instance