# Mobile development with Flutter

## Download and extract flutter sdk

https://flutter.dev/docs/get-started/install/windows

setup global path environment pointing to flutter´s bin folder.

## Run flutter doctor to check pending installations

In command prompt 
```
flutter doctor
```
Review the exclamation marks
```
Doctor summary (to see all details, run flutter doctor -v):
[√] Flutter (Channel stable, v1.12.13+hotfix.9, on Microsoft Windows [Version 10.0.18363.778], locale en-US)
[!] Android toolchain - develop for Android devices (Android SDK version 29.0.3)
    X Android license status unknown.
      Try re-installing or updating your Android SDK Manager.
      See https://developer.android.com/studio/#downloads or visit https://flutter.dev/setup/#android-setup for detailed
      instructions.
[!] Android Studio (version 3.6)
    X Flutter plugin not installed; this adds Flutter specific functionality.
    X Dart plugin not installed; this adds Dart specific functionality.
[!] VS Code (version 1.44.2)
    X Flutter extension not installed; install from
      https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter
[!] Connected device
    ! No devices available

! Doctor found issues in 4 categories.
```
## Download and install Android Studio

We must install the flutter and dart plugins in Android Studio.

In Welcome Android Studio, select Configure > Settings.
Then in the left panel, under Plugins > Browse repositories. 
Then enter Flutter (flutter.dev) and click in the Install button. This will install flutter and dart plugins.

Then restart android studio to reflect changes.

When opening the Welcome screen again, a new item will show up, called
**Start a new Flutter project**

Install visual code and download flutter extension at https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter

Now if you check `flutter doctor`, we will have Android toolchain missing.

Accept the licenses
```
flutter doctor --android-licenses
```

In case you have an error 
```
Android sdkmanager tool not found (C:\Users\junio\AppData\Local\Android\sdk\tools\bin\sdkmanager).
Try re-installing or updating your Android SDK,
visit https://flutter.dev/setup/#android-setup for detailed instructions.
```
Try to install older Android SDK by unhiding Obsolete Packages (https://github.com/flutter/flutter/issues/51712)

Then run `flutter doctor` to check if toolchain and licenses were accepted
```
Doctor summary (to see all details, run flutter doctor -v):
[√] Flutter (Channel stable, v1.12.13+hotfix.9, on Microsoft Windows [Version 10.0.18363.778], locale en-US)

[√] Android toolchain - develop for Android devices (Android SDK version 29.0.3)
[√] Android Studio (version 3.6)
[√] VS Code (version 1.44.2)
[!] Connected device
    ! No devices available

! Doctor found issues in 1 category.
```

## Configure android device manager

Create a new flutter app with the default values. Go to AVD Manager (Android Virtual Device Manager) icon.

Download x86 image to create the vm. This might take several minutes. :-/
