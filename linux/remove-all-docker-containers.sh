#!/bin/bash
clear
echo '**********************************************'
echo 'Removing all docker images...'
echo $'**********************************************\n\n'
echo 'Stopping all containers...'
docker stop $(docker ps -a -q)

echo 'Removing all containers...'
docker rm $(docker ps -a -q)