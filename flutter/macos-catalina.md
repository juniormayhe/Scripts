# Install java in MacOS

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

When opening a new `Terminal`, enter `java -version` and you will get something as "java version 1.8.0_251".

# Remove java

To remove Java completely, go to Terminal 
```
rm -rf /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin  
sudo rm -rf /Library/PreferencePanes/JavaControlPanel.prefPane  
sudo rm -rf /Library/Application\ Support/Oracle/Java/ 
sudo rm -rf /Library/Java/JavaVirtualMachines 
```

ref https://explainjava.com/uninstall-java-macos/

# Install cocoapods

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
