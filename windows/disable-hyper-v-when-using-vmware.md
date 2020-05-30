When VMWare shows an error message telling it is not compatible with Device/Credential Guard, we can disable hyperv to solve this problem.

Disable temporarily hyperv

```batch
@echo off 
echo execute this bat as admin
bcdedit /set hypervisorlaunchtype off

echo Press any key to reboot
pause>nul
shutdown /f /r /t 00
```

Reenable  hyperv

```batch
@echo off 
echo execute this bat as admin
bcdedit /set hypervisorlaunchtype auto

echo Press any key to reboot
pause>nul
shutdown /f /r /t 00
```
