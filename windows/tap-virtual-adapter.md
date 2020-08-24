
TAP, namely network TAP, simulates a link layer device and operates in layer 2 carrying Ethernet frames. You can add TAP adapters to allow connecting to multiple VPNs at the same time.

![](https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/Tun-tap-osilayers-diagram.png/400px-Tun-tap-osilayers-diagram.png)

Scripts below require [C:\Program Files\TAP-Windows\bin\tapinstall.exe](https://github.com/juniormayhe/Scripts/blob/master/windows/tapinstall.exe)

# Remove all TAP virtual adapters
```bat
echo WARNING: this script will delete ALL TAP virtual adapters (use the device manager to delete adapters one at a time)
pause
"C:\Program Files\TAP-Windows\bin\tapinstall.exe" remove tap0901
pause
```

# Add TAP virtual adapter
```bat
rem Add a new TAP virtual ethernet adapter
"C:\Program Files\TAP-Windows\bin\tapinstall.exe" install "C:\Program Files\TAP-Windows\driver\OemVista.inf" tap0901
pause
```

