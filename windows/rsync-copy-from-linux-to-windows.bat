@ECHO OFF
ECHO *****************************************************************
ECHO Backup files from linux to windows using cwrsync
ECHO there might be issues when copying Linux long file names into Windows
ECHO *****************************************************************

REM Make environment variable changes local to this batch file
SETLOCAL

SET INICIO=%TIME%

REM ** CUSTOMIZE ** Specify where to find rsync and related files (C:\CWRSYNC)
SET CWRSYNCHOME=%~dp0
rem SET CWRSYNCHOME=C:\Temp\cwRsync_5.5.0_x86_Free

REM Create a home directory for .ssh 
IF NOT EXIST %CWRSYNCHOME%\home\%USERNAME%\.ssh MKDIR %CWRSYNCHOME%\home\%USERNAME%\.ssh

REM Set HOME variable to your windows home directory. That makes sure
REM that ssh command creates known_hosts in a directory you have access.
rem set HOME=./

REM Make cwRsync home as a part of system PATH to find required DLLs
SET CWOLDPATH=%PATH%
SET PATH=%CWRSYNCHOME%\BIN;%PATH%

rem IF NOT EXIST c:\Temp\BackupData MKDIR c:\Temp\BackupData

rem rsync -trzv -p --chmod=ugo=rwX root@192.168.1.212:/usr/share/* /cygdrive/c/BackupData/
rem rsync -trzh --progress --stats -p --chmod=ugo=rwX root@192.168.1.212:/* /cygdrive/c/BackupData/
rsync -aAzh --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} / /cygdrive/c/full-backup

SET FIM=%TIME%
echo ----------------
echo INICIO %INICIO%
echo FIM    %FIM%
