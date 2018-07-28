echo deleting files from %1 days ago
forfiles /p "C:\folder\subfolder" /s /m *.* /D -%1 /C "cmd /c del @path"
