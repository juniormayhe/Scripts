# Emulate linux commands in windows command prompt

in a batch file:

```
@echo off
doskey ls=dir $*
doskey mv=move $*
doskey cp=copy $*
doskey cat=type $*
```
