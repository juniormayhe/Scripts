# Dart

## Set alias to flutter pub in Windows

Assuming flutter is in global path:

```
@echo off
doskey pub=flutter.bat pub $*
```

### Set alias for gitbash on Windows

```
echo alias pub='/c/flutter/bin/flutter.bat pub'> c:\users\%username%\.bashrc
```

## Set alias to flutter pub in Linux
```
alias pub='/c/flutter/bin/flutter.bat pub'
```


