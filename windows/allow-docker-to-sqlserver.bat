@echo off
echo Allowing Docker for Windows (172.x.x.x) to connect to SQL Server (localhost 192.168.x.x)
netsh advfirewall firewall add rule name=DockerSQLPort dir=in protocol=tcp action=allow localport=1433 remoteip=localsubnet profile=DOMAIN