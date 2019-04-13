# Prepare to connect to Android device via USB

## In Android

- Enable developer options
- Enable USB debugging

## In Windows 10
- Install Android SDK (plataform tools)
- Run adb at C:\Program Files (x86)\Android\android-sdk\platform-tools

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
