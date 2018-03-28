REM Download requirements
ECHO https://docs.microsoft.com/en-us/sysinternals/downloads/pstools

REM Execute process on remote user machine
psexec \\192.168.1.157 -h -u DOMAIN\domain_controller_user -p contrasena "%windir%\system32\notepad.exe"
 
REM Kill process on remote user machine
pskill -t \\192.168.1.157 -u DOMAIN\domain_controller_user -p contrasena notepad.exe
