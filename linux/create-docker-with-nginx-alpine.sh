#!/bin/bash
LOCALHOST_PATH=/some/content
CONTAINER_NAME=webserver
DOCKERIZED_HOSTNAME=meu-servidor
clear
echo "**********************************************"
echo "Assuming you will use nginx:alpine official image,"
echo "this script will create a new docker container with nginx,"
echo "accept tcp connection from all ports and point your"
printf $"local application path $LOCALHOST_PATH to docker's /usr/share/nginx/html"
echo "**********************************************"
docker run --name webserver -v $LOCALHOST_:/usr/share/nginx/html:ro -t -h $DOCKERIZED_HOSTNAME -P -d nginx:alpine nginx -g 'daemon off;'

#wanna go back to tty?
echo "Entering bash in Alpine"
docker exec -it webserver /bin/sh

echo "If you had to stop with docker stop $CONTAINER_NAME, to start again run docker start -a $CONTAINER_NAME"