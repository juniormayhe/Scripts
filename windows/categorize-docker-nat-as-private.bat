@echo off
echo This avoids Docker firewall message when DockerNAT network category is set Internal in HyperV
echo we must change it to Private...
echo Please run this as administrator
powershell Set-NetConnectionProfile -interfacealias \"vEthernet (DockerNAT)\" -NetworkCategory Private
echo Now you can share again C drive in Docker for Windows.
