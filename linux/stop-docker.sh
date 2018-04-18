#!/bin/bash
echo "Parando docker con imagen de pentaho"
docker images | awk '{if ($1=="docker.io/taxindividual/pentaho") { docker container kill $3;} }'
