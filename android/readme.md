# Prepare to connect to Android device via USB

## In Android

- Enable developer options
- Enable USB debugging

## In Windows 10
- Install Android Studio (which has platform tools)
- Run adb at C:\Users\junio\AppData\Local\Android\Sdk\platform-tools

## Configure
```
C:\WINDOWS\system32>set ANDROID_PLATFORM_TOOLS="C:\Users\junio\AppData\Local\Android\Sdk\platform-tools"
C:\WINDOWS\system32>set ANDROID_TOOLS="C:\Users\junio\AppData\Local\Android\Sdk\build-tools\32.1.0-rc1"
C:\WINDOWS\system32>set path=%path%;%ANDROID_PLATFORM_TOOLS%;%ANDROID_TOOLS%
```
# List apps / packages
```
adb shell pm list packages
```

## Show app/ APK path
```
adb shell pm path br.com.bb.android
```

## Pull apk entering source the path into current folder
```
adb pull /data/app/br.com.bb.android-cOmJefZ-g0MSY4Nc2F3vAQ==/base.apk .
```
