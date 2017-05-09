@echo off 
echo execute este bat como admin
bcdedit /set hypervisorlaunchtype off
echo Enter para reboot
pause>nul
shutdown /f /r /t 00
