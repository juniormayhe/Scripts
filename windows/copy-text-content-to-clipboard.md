# Copy file text content to clipboard

Text files, json, js, ts, yaml

```reg
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\SystemFileAssociations\text\shell\copytoclip]
@="Copy to Clipboard"

[HKEY_CLASSES_ROOT\SystemFileAssociations\text\shell\copytoclip\command]
@="cmd.exe /c type \"%1\" | clip.exe"

[HKEY_CLASSES_ROOT\SystemFileAssociations\.json\shell\copytoclip]
@="Copy to Clipboard"

[HKEY_CLASSES_ROOT\SystemFileAssociations\.json\shell\copytoclip\command]
@="cmd.exe /c type \"%1\" | clip.exe"

[HKEY_CLASSES_ROOT\SystemFileAssociations\.js\shell\copytoclip]
@="Copy to Clipboard"

[HKEY_CLASSES_ROOT\SystemFileAssociations\.js\shell\copytoclip\command]
@="cmd.exe /c type \"%1\" | clip.exe"

[HKEY_CLASSES_ROOT\SystemFileAssociations\.ts\shell\copytoclip]
@="Copy to Clipboard"

[HKEY_CLASSES_ROOT\SystemFileAssociations\.ts\shell\copytoclip\command]
@="cmd.exe /c type \"%1\" | clip.exe"

[HKEY_CLASSES_ROOT\SystemFileAssociations\.yaml\shell\copytoclip]
@="Copy to Clipboard"

[HKEY_CLASSES_ROOT\SystemFileAssociations\.yaml\shell\copytoclip\command]
@="cmd.exe /c type \"%1\" | clip.exe"
```
