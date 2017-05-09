@echo off
cls
ECHO ***********************
ECHO WELCOME TO XYZ COMPANY
ECHO ***********************

ECHO MAPPING NETWORK DRIVES...

REM each user has his/her own folder
IF NOT EXIST H:\ (
	NET USE H: \\remote-host\shared-folder\%username% /PERSISTENT:NO
)

REM run groupname to figure out user primary group in Active Directory
@for /f "tokens=*" %%F in ('\\dc01\NETLOGON\groupname.exe 1') do @set g=%%F
IF NOT EXIST G:\ (
	NET USE G: \\remote-host\shared-folder\groups \%g% /PERSISTENT:NO
)

REM map a common public folder for all users
IF NOT EXIST T:\ (
	NET USE T: \\remote-host\shared-folder\everyone /PERSISTENT:NO
)


REM MKDIR C:\company-notices
REM COPY T:\some-corporate-video.mp4 C:\company-notices
REM TIMEOUT 30
REM CALL C:\company-notices\some-corporate-video.mp4