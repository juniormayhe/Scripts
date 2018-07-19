@ECHO OFF
ECHO *****************************************************************
ECHO Copy files from Asterisk (on Linux) to Windows  
ECHO Before using this batch, install https://cygwin.com/install.html
ECHO *****************************************************************

SETLOCAL

SET CWRSYNCHOME=C:\cygwin64
SET PATH=%CWRSYNCHOME%\BIN;%PATH%

ECHO Copy data to a root folder named TargetFolder on Drive C (this will not work with too many files)
ECHO on local server generate ssh-keygen -t rsa and paste id_rsa.pub content into remote server's /root/.ssh/authorized_keys
REM rsync -trzh --progress --stats -p --chmod=ugo=rwX root@192.168.0.7:/var/spool/asterisk/monitor/* /cygdrive/c/TargetFolder

REM Since * will expand to multiple files this can throw too many arguments error on rsync, the workaround is to avoid * and filter results
find /var/spool/asterisk/monitor/ | grep .gsm | rsync -trzh --progress --stats -p --chmod=ugo=rwX root@192.168.0.7:/var/spool/asterisk/monitor/$1 /cygdrive/c/TargetFolder
