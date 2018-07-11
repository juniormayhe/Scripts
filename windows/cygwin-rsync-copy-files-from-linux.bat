@ECHO OFF
ECHO *****************************************************************
ECHO Copy files from Asterisk (on Linux) to Windows  
ECHO Before using this batch, install https://cygwin.com/install.html
ECHO *****************************************************************

SETLOCAL

SET CWRSYNCHOME=C:\cygwin64
SET PATH=%CWRSYNCHOME%\BIN;%PATH%

ECHO Copy data to a root folder named TargetFolder on Drive C
ECHO infotaxi123 | ls -l
REM infotaxi123 | rsync -trzh --progress --stats -p --chmod=ugo=rwX root@192.168.0.7:/var/spool/asterisk/monitor/* /cygdrive/c/TargetFolder
