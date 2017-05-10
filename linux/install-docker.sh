#!/bin/bash
DOCKERUSER=junior
clear
echo "******************************************"
echo "Preparing for docker installation on Fedora..."
echo "******************************************"

echo "Installing package to manage dnf repositories for docker..."
dnf -y install dnf-plugins-core

echo "Adding repo for docker..."
dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

echo "Updating Linux dnf package..."
dnf makecache fast

echo "Installing latest docker community edition..."
dnf -y install docker-ce

echo "Starting and enabling docker..."
systemctl enable docker
systemctl start docker

echo "Adding a docker group (could already exists)..."
groupadd docker

echo "Adding user to docker group..."
usermod -aG docker $DOCKERUSER 