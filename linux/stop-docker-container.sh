#!/bin/bash
echo "Stop docker image"
docker stop CONTAINER_NAME
docker rm CONTAINER_NAME
docker kill CONTAINER_NAME
