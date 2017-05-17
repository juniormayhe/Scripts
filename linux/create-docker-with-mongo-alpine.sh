#!/bin/bash
LOCALHOST_PATH=/some/data
CONTAINER_NAME=banco
DOCKERIZED_HOSTNAME=meu-banco
clear
echo "**********************************************"
echo "Assuming you will use mvertes/alpine-mongo image,"
echo "this script will create a new docker container with mongodb,"
echo "accept tcp connection from 27017 port ports and point your"
printf $"local application path $LOCALHOST_PATH to docker's /usr/share/nginx/html"
echo "**********************************************"
docker run --name $CONTAINER_NAME -v $LOCALHOST_PATH:/data/db -t -h $DOCKERIZED_HOSTNAME -p 27017:27017 -d mvertes/alpine-mongo

#wanna go back to tty?
echo "Entering bash in Alpine"
docker exec -it $CONTAINER_NAME /bin/sh

echo "If you had to stop with docker stop $CONTAINER_NAME, to start again run docker start -a $CONTAINER_NAME"