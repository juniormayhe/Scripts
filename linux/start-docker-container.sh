#!/bin/bash
# if netcore Program.cs contains .UseUrls("http://*:5100"), the internal port within container will be 5100, external can be the same or other
echo "starting docker... 8080 port should be free at hosting OS, internal port will be 5100
docker run -p 8080:5100 --rm --name myapp company/imagename

#to start TWO docker containers use (UseUrls must be defined in Program.cs of both NET Core WebApi and Web projects): 
#docker run -p 5100:5100 --rm --name myapi company/myapi & docker run -p 8080:8080 --rm --name mywebapp company/mywebapp 
