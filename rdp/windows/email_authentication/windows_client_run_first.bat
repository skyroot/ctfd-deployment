@echo OFF
:: v2
:: uses default SSH client on Windows (Windows 10 or if the computer has Git installed) establish a local port forward to the remote machine RDP nodes
:: prompt the user for user login id
:: the USERS gateway will prompt password authentication
:: does not rely on plink.exe or sending the password in clear via batch because not easy to escape batch special characters such as "|", "\"
:: rdp to the local port

echo ========== "   _____ _______ ______ " ==========
echo ========== "  / ____|__   __|  ____|" ==========
echo ========== " | |       | |  | |__   " ==========
echo ========== " | |       | |  |  __|  " ==========
echo ========== " | |____   | |  | |     " ==========
echo ========== "  \_____|  |_|  |_|     " ==========
echo ========== "                        " ==========
echo ========== "                        " ==========
echo 1. Enter your email address which you register at https://ncl.sg
echo 2. Enter the node address and port number
echo 3. Enter your password when prompted
echo 4. If authentication is successful, you will see the terminal like this [user_login_id]@users$
echo 5. Double click on the second batch script
echo ALWAYS KEEP THE TERMINAL OPEN
echo.

set /p username=Enter email address (ncl.sg) : 

set /p node_address=Enter node address with port number delimted by a colon, e.g. n0.exp.team.ncl.sg:11000 : 

:: username contains email address
:: get uid from file
:: delimit the file [email]:[uid]
:: %a is email, %b is username
SETLOCAL ENABLEDELAYEDEXPANSION

if /I "!username:@=!" neq "!username!" (
  for /f "tokens=1,2 delims=:" %%a in (file) do (
	:: grab the real username
	set line=%%a
	if "!username!"=="!line!" (
	  set username=%%b
	)
  )
)

:: local port forward
:: change this n2.[exp_name].[team].ncl.sg:[rdp 11100-11103] to respective address for the students
:: may prompt whether to accept key or not, select yes
start /b ssh -L 127.0.0.1:23456:%node_address% !username!@users.ncl.sg

PAUSE >nul
ENDLOCAL
