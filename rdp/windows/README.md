# Windows Remote Desktop Client Batch Script
This is a batch script designed to connect to a virtual machine on a physical node by performing these two tasks:
1. Perform a local port forward to one of the remote desktop ports (opened by virtualbox) via **NCL USERS**
1. Execute Microsoft's Remote Desktop Connection client to the local port

## Requirements
* Powershell
* Port of your choice must be opened on the physical node

## Additional Software Used
* Putty plink version 0.70

## Usage
1. In the *windows* directory, execute `windows_client.bat`
2. Enter `NCL user login id` and `NCL password`
3. The terminal would prompt for the **node address**, e.g. *n0.exp.team.ncl.sg:remote_port*
3. Upon successful connection, you would see a message: *"Please do not close this window..."*

## Notes
Default local port is set to `23456`; customize to own taste if necessary
