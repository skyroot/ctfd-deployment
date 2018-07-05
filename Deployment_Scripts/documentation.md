# For CTFd client nodes:

## modify_hosts.sh

To add or remove a line in /etc/hosts file to point a hostname to the IP address.

```sudo ./modify_hosts.sh add <ip_address> <hostname>```

Example as DETERLab command for new client nodes:

> tb-set-node-startcmd $n0 "sudo /share/ctfd/modify_hosts.sh add 10.64.0.19 ctf.ncl.sg"

# For CTFd server VM:

## install_ctfd_prerequisites.sh

To install prerequisites for CTFd, including setting up uWSGI and nginx.

Must be run once.

```sudo ./install_ctfd_prerequisites.sh```

## add_ctfd_instance.sh

To create a new CTFd instance.

```sudo ./add_ctfd_instance.sh <hostname> <ctf_name> <admin_ncl_email>```

- *hostname* can be any URL
- *ctf_name* is the name shown on the CTF website banner
- *admin_ncl_email* is the ncl.sg login email of this CTF's admin **(Please make sure that this is correct)**

For example:

> sudo ./add_ctfd_instance.sh cs4238.ctf.ncl.sg "CS4238 CTF" ncl.vte1@gmail.com

## start_ctfd_instance.sh

To start an existing CTFd instance.

```sudo ./start_ctfd_instance.sh <hostname>```

## stop_ctfd_instance.sh

To stop a running CTFd instance.

```sudo ./stop_ctfd_instance.sh <hostname>```

## remove_ctfd_instance.sh

To stop and remove an existing CTFd instance.

```sudo ./remove_ctfd_instance.sh <hostname>```
