# Windows Remote Desktop Client Batch Script
This is a batch script designed to connect to a virtual machine on a physical node by performing these two tasks:
1. Perform a local port forward to one of the remote desktop ports (opened by virtualbox) via **NCL USERS**
1. Execute Microsoft's Remote Desktop Connection client to the local port

## Requirements
* Port of your choice must be opened on the physical node

## Additional Software Used
* Windows built-in SSH client (Windows 10 / Installed by Git)

## Usage
1. In the *windows* directory, execute `windows_client_run_first.bat`
1. Enter `NCL user login id`
1. The terminal would prompt for the **node address**, e.g. *n0.exp.team.ncl.sg:remote_port*
1. The terminal would prompt for the password, enter your `NCL password` which you used at https://ncl.sg
1. Upon successful authentication, you will see this: `[user_id]@users$` **(KEEP THIS TERMINAL OPEN THROUGHOUT YOUR SESSION)**
1. Back on the Windows, execute `rdp.bat` to establish the connection to the machine

## Notes
Default local port is set to `23456`; customize to own taste if necessary
