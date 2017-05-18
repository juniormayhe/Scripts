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
echo "Now enter in mongo in order to create an admin user as indicated in https://docs.mongodb.com/manual/tutorial/enable-authentication/ then press any key to continue."
read -n 1 -s -p $'\nor CTRL+C to abort'

echo "Entering bash in Alpine"
docker exec -it $CONTAINER_NAME mongo --port 27017

echo "Now that you have created the admin user, you must remove the old container and recreate it running:"
printf $"docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME\n\n"

echo "and then run docker again with auth parameter:"
echo "docker run --name $CONTAINER_NAME -v $LOCALHOST_PATH:/data/db -t -h $DOCKERIZED_HOSTNAME -p 27017:27017 -d mvertes/alpine-mongo mongod --auth"
echo "Enter mongo and test your admin user authentication"
echo "docker exec -it $CONTAINER_NAME mongo"
