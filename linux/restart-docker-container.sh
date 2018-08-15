#!/bin/bash
echo "Stopping docker"
docker stop myapp
docker rm myapp
docker kill myapp

echo "Restarting docker"
docker run -p 80:5001 --rm --name myapp company/imagename
