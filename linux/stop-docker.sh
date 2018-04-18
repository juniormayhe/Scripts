#!/bin/bash
echo "Stop docker image with pentaho"
docker images | awk '{if ($1=="docker.io/taxindividual/pentaho") { docker container kill $3;} }'
