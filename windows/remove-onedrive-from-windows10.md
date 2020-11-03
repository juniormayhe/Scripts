```cmd
@echo off
echo remove onedrive
taskkill /f /im OneDrive.exe

echo uninstalling 64 bits
%SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall

rem echo uninstalling 32 bits
rem %SystemRoot%\System32\OneDriveSetup.exe /uninstall

echo press any key to reboot...
pause > nul

shutdown /t 00 /f /r
```
