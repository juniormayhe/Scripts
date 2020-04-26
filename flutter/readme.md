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

Change the vm configuration, in *Emulated performance*, select Hardware GLES 2.0 if you have a graphic card for faster rendering.

Click on the play button to start the vm for the virtual device.

## Lauch the app

In Android Studio top bar select the Android SDK built then click on Play button to lauch the flutter app.

## Basic flutter app

Scaffold class can be used to create a basic flutter app. Under projects add a new folder called images and drop into that the images you want to pack in the app.

Edit the pubspec.yaml to tell where to pick asset images:
```
flutter:
  ...
  # you can name the specific image file or use all images by adding only "foldername/"
  assets:
    - images/
```

Edit main.dart to use a Scaffold class to show the image:

```
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.deepPurple[100],
        appBar: AppBar(
          title: Text(
            'I am Rich',
          ),
          backgroundColor: Colors.deepPurple[600],
        ),
        body: Center(
          child: Image(
            image: AssetImage('images/diamond.png'),
          ),
        ),
      ),
    ),
  );
}
```
To generate app icon for an original of 1024x1024 px, you can go to https://appicon.co/ then

- delete the Android folders in testing_app\android\app\src\main\res\mipmap*
- copy the android generated mipmap folders to testing_app\android\app\src\main\res\
- delete the iOS folder \testing_app\ios\Runner\Assets.xcassets\AppIcon.appiconset
- copy the iOS generated folder to \testing_app\ios\Runner\Assets.xcassets\AppIcon.appiconset


