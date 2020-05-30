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

When opening a new `Terminal`, enter `java -version` and you will get something as "java version 1.8.0_251".
