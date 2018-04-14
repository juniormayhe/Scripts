ECHO Return the logged in user of a remote Windows computer identified by DESIRED-IP-ADDRESS
wmic.exe /node:DESIRED-IP-ADDRESS computersystem get username
