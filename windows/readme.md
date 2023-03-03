# Emulate linux commands in windows command prompt

in a batch file:

```
@echo off
doskey ls=dir $*
doskey mv=move $*
doskey cp=copy $*
doskey cat=type $*
```

# Copy files and overwrite
```
@echo off
xcopy /s /y /e /i /h /q /d /r /k /c "G:\My Drive\shield-data" "C:\Users\wanderley.junior\myapp\src\data\"
```
