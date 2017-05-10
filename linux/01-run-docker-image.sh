#!/bin/bash
CONTAINER_NAME=mean-exercises
IMAGE=fedora
PORT=80
clear
echo '**********************************************'
echo $"Running docker image on Host OS with container name $CONTAINER_NAME..."
echo "If you exit you have to start again with docker start <container-name>"
echo $'**********************************************\n\n'
printf $"Running $IMAGE and exposing port $PORT. Type exit to quit docker OS\n\n"
if [ ! "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=$CONTAINER_NAME)" ]; then
        # cleanup
        docker rm $CONTAINER_NAME
    fi
fi
# run your container
docker run --name $CONTAINER_NAME -i -t -p $PORT:$PORT $IMAGE /bin/bash


