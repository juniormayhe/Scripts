Windows 11 Explorer auto-assigns a folder template based on what it detects inside. Five templates exist: General Items, Documents, Pictures, Music, Videos. The Music template forces those columns (#, Title, Contributing Artists, Album).
The detection is aggressive and sticky toward Music. If Explorer sees a handful of audio files, it flags the whole folder as Music — even if most files are documents. Once it picks Music, it persists that choice in the ShellBag (the BagMRU/Bags keys), so it sticks across sessions.
  
```ps
# 1. Close Explorer
Stop-Process -Name explorer -Force

# 2. Wipe existing bags
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" /f
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags" /f

# 3. Set global General Items default
$key = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell"
New-Item -Path $key -Force | Out-Null
Set-ItemProperty -Path $key -Name "FolderType" -Value "NotSpecified" -Type String

# 4. Restart Explorer
Start-Process explorer
```
