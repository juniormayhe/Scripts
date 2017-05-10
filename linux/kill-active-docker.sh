#!/bin/bash
clear
echo "******************************************"
echo "Killing active docker containers..."
echo "******************************************"
docker ps -q | docker kill  | docker ps -q