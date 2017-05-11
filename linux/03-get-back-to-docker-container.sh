#!/bin/bash
CONTAINER_NAME=mean-exercises
clear
echo '**********************************************'
echo "So you exited the container? Getting into container $CONTAINER_NAME..."
echo $'**********************************************'
echo $"Starting container $CONTAINER_NAME..."
docker start $CONTAINER_NAME
printf $"\nAttaching you to the existing container $CONTAINER_NAME...\n"
docker attach $(docker ps -q)
#printf $"\nExecuting container $CONTAINER_NAME...\n"
#docker exec -it $CONTAINER_NAME /bin/bash
echo "You exited the container $CONTAINER_NAME"
docker start $CONTAINER_NAME