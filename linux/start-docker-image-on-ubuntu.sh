#!/bin/bash
echo "starting docker... 8080 port should be free at hosting OS
docker run -p 8080:80 --rm --name myapp company/imageondockerhub
