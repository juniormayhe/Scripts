#!/bin/bash
# if netcore Program.cs contains .UseUrls("http://*:5100"), the internal port within container will be 5100, external can be the same or other
echo "starting docker... 8080 port should be free at hosting OS, internal port will be 5100
docker run -p 8080:5100 --rm --name myapp company/imagename
