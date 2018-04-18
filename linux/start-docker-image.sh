#!/bin/bash
echo "Starting docker with Pentaho image (previously pulled with docker login and docker pull)"
printf "Visit Pentaho con la URL: http://" && ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.)-9]*' | grep -v '127.0.0.1' | grep -v '172' && printf ":8080"
docker run --rm -p 8080:8080 -v /opt/pentaho/biserver-ce:/opt/biserver-ce --name pentaho taxindividual/pentaho
