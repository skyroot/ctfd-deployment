@echo OFF
:: prompt the user for user login id and password
:: uses Putty plink.exe establish a local port forward to the remote machine RDP nodes
:: rdp to the local port

echo ==============================
echo ============ CTF =============
echo ==============================
echo.

set /p username=Enter user login id: 

powershell -Command $pword = read-host "Enter password" -AsSecureString ; ^
    $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword) ; ^
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR) > .tmp.txt 
set /p password=<.tmp.txt & del .tmp.txt

set /p node_address=Enter node address with port number delimted by a colon, e.g. n0.exp.team.ncl.sg:11000 : 

:: change this n2.[exp_name].ite-cynsctf.ncl.sg:[rdp 11100-11103] to respective address for the students
:: e.g. n1.ctfpractice1.ite-cynsctf.ncl.sg:11100 
start /b %~dp0plink.exe -N -L 127.0.0.1:23456:%node_address% -l %username% -pw %password% %username%@users.ncl.sg

echo.
echo Session established successfully.
echo.
echo ***** PLEASE DO NOT CLOSE THIS WINDOW TO KEEP SESSION ALIVE *****
echo.

mstsc.exe /v:127.0.0.1:23456 /w 1366 /h 768