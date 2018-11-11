@echo OFF
echo ==============================
echo rdp command to establish a remote connection to a VM
echo execute this after the local port forward link has been establish
echo edit the [local port] if necessary
echo ==============================
echo.

cmd /C mstsc.exe /v:127.0.0.1:23456 /w 1366 /h 768
