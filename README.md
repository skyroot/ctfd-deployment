# ctfd
Repository for CTFd deployment in NCL

## ctfd_instance_manager.py

Handles the creation, deletion, starting and stopping of CTFd instances on CTFd server VM.

Listens to **socket 0.0.0.0:8887** for commands, then calls the corresponding scripts in Deployment_Scripts.

### Running this server program

```sudo python ./ctfd_instance_manager.py```

### Client program

Clients can use Netcat or other applications to send commands to this server program.

```echo 'add cs4238.ctf.ncl.sg "CS4238 CTF" ncl.vte1@gmail.com' | nc 0.0.0.0 8887```

### List of accepted commands 

```list```: Lists all existing CTFd instances and their hostnames

```add <hostname> <ctf_name> <admin_ncl_email>```: Adds a new CTFd instance

```start <hostname>```: Starts an existing CTFd instance

```stop <hostname>```: Stops a running CTFd instance

```remove <hostname>```: Removes an existing CTFd instance