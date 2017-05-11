#!/bin/bash
PROJECT_NAME=mean-exercises
DOCKERUSER=junior
clear
echo '**********************************************'
echo 'Preparing for docker installation on Fedora Host OS...'
echo 'Note: Run this on Host OS'
echo $'**********************************************\n'

echo $'ATTENTION: Before proceed you must disable SELINUX:' 
echo $'$ sudo vim /etc/selinux/config'
echo $'    SELINUX=disabled' 
echo $'$ reboot\n\n'

read -n 1 -s -p $'If SELinux is already disabled, press any key to start docker installation\nor CTRL+C to cancel...\n\n'

echo 'Installing package to manage dnf repositories for docker...'
dnf -y install dnf-plugins-core

echo 'Adding repo for docker...'
dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

echo 'Updating Linux dnf package...'
dnf makecache fast

echo 'Installing latest docker community edition...'
dnf -y install docker-ce

echo 'Starting and enabling docker...'
systemctl enable docker
systemctl start docker

echo 'Adding a docker group (could already exists)...'
groupadd docker

echo 'Adding user to docker group...'
usermod -aG docker $DOCKERUSER 

echo 'Restarting docker to identify new docker user...'
systemctl start docker

echo 'Turning off firewalld for exposing HTTP navigation...'
sudo systemctl stop firewalld
sudo systemctl disable firewalld

echo "#!/bin/bash
#assuming your container is 172.17.0.2
172.17.0.2 $PROJECT_NAME" > /etc/profile.d/start-nginx.sh


docker --version
echo $"Now you can run your container with docker run --name <CONTAINER_NAME> -i -t -p <PORT>:<PORT> $IMAGE /bin/bash"