# ctfd
Repository for CTFd deployment in NCL

## ctfd_instance_manager.py

Handles the creation, deletion, starting and stopping of CTFd instances on CTFd server VM.

Listens to **socket 0.0.0.0:8887** for commands, then calls the corresponding scripts in Deployment_Scripts.

This program should be kept running in the background, otherwise all CTFd instances will be stopped.

### Running this server program

#### To start in background:

1. Type ```nohup sudo python ./ctfd_instance_manager.py```

(Enter your sudo password if prompted)

2. Enter `ctrl + Z`

3. Type ```bg```

It may take a few minutes for the server listener to start completely.

#### To stop this program:

```sudo pkill -9 python```

### Client program

Clients can use Netcat or other applications to send commands to this server program.

```echo 'add cs4238.ctf.ncl.sg "CS4238 CTF" ncl.vte1@gmail.com' | nc 0.0.0.0 8887```

### List of accepted commands 

```list```: Lists all existing CTFd instances and their hostnames

```add <hostname> <ctf_name> <admin_ncl_email>```: Adds a new CTFd instance

```start <hostname>```: Starts an existing CTFd instance

```stop <hostname>```: Stops a running CTFd instance

```remove <hostname>```: Removes an existing CTFd instance