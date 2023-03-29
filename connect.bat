

@echo off

setlocal

REM Configuration files directory
set CONFIG_DIR=D:\MyProject\mybat\vpnconf

REM Username and password file path
set AUTH_FILE=D:\MyProject\mybat\auth.txt

REM Loop through all configuration files
for %%f in ("%CONFIG_DIR%\*.ovpn") do (
    echo Attempting to connect "%%f"
    start "" "C:\Program Files\OpenVPN\bin\openvpn.exe" --config "%%f" --connect-retry-max 3 --connect-retry 1  --auth-user-pass "%AUTH_FILE%"  2>&1 | findstr /i /c:"Initialization Sequence Completed"
    echo  %errorlevel%
    REM Check if connected successfully
    ping -n 1 google.com > nul
    if %errorlevel% equ 0 (
        echo Connected successfully!
        exit /b 0
    ) else (
        echo Connection failed, trying the next configuration file...
    )
)

echo Failed to connect to the proxy server!
exit /b 1

