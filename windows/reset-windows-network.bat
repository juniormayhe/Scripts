@echo off
echo ******************************
echo Resetting Windows network
echo ******************************
ipconfig /flushdns
ipconfig /registerdns
ipconfig /release
ipconfig /renew
NETSH winsock reset catalog
NETSH int ipv4 reset reset.log
NETSH int ipv6 reset reset.log
echo Press any key to reboot... or CTRL C to abort
pause >nul
shutdown /f /r /t 00