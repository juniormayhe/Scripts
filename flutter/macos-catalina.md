# Prepare flutter dev environment for MacOS

## Download Flutter

Unzip and move flutter folder to `Users/<your name>/Developer/flutter`

Open Terminal and accept licenses
```
flutter doctor --android-licenses
```

## Install java in MacOS

When running flutter doctor in MacOS Catalina an error message may appear

```
unable to find any JVMs matching version "1.8"
```

To configure java in MacOS Catalina, remove any JDKs previously installed 

```
sudo rm -fr /Library/Java/JavaVirtualMachines/jdk-<desired version>.jdk`
```

Download jre and jdk of the same version from java.com:

- `jre-8u251-macosx-x64.dmg`
- `jdk-8u251-macosx-x64.dmg` 

and install them.

Installing process needs to allow installation in *System Preferences > Security & Privacy > General > Open anyway* button. 

Edit .bash_profile with *vim* to add the java home
```
export JAVA_HOME=$(/usr/libexec/java_home)
or
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
```

That will render export `JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_251.jdk/Contents/Home`


When opening a new `Terminal`, enter `java -version` and you will get something as "java version 1.8.0_251".

## Remove java

To remove Java completely, go to Terminal 
```
rm -rf /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin  
sudo rm -rf /Library/PreferencePanes/JavaControlPanel.prefPane  
sudo rm -rf /Library/Application\ Support/Oracle/Java/ 
sudo rm -rf /Library/Java/JavaVirtualMachines 
```
ref https://explainjava.com/uninstall-java-macos/

## Edit bash profile

Edit .bash_profile to add
```
export PATH="$PATH:/Users/<your name>/Developer/flutter/bin"
```

Edit .zshrc

vim .zshrc
```
export PATH="$PATH:$HOME/Developer/flutter/bin"
```

## Install Xcode and cocoapods

Install xcode from App Store. IT WILL TAKE A LONG TIME.

Accept xcode license
```
sudo xcodebuild -license accept
```

Configure xcode command line tools to use latest xcode
```
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

Install cocoapods
```
sudo gem install cocopods
```

## Install Android studio

Download and open dmg file. In the new Android Studio 4.0.0 window, drag and drop *Android Studio* icon to *Applications* folder.
Ref: https://developer.android.com/studio/install

## Run flutter doctor

In terminal, check if flutter environment is ready

```
flutter doctor
```
