
# Docker

## Docker commands for Ubuntu 

Main docker commands: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04

## Ubuntu /etc/apt/sources.list

```
deb http://archive.ubuntu.com/ubuntu bionic main
deb http://archive.ubuntu.com/ubuntu bionic-security main
deb http://archive.ubuntu.com/ubuntu bionic-updates main
deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable
```

## Publishing docker image on Docker Hub

Create an account at https://hub.docker.com/u/company/

Setup docker login at CLI
```
docker login
```

Create your NET Core app with a dockerfile at Project folder such as 

```
FROM microsoft/dotnet:sdk AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM microsoft/dotnet:aspnetcore-runtime
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "MyWebApp.dll"]
```

If you csproj depends on other csprojs, go to root application folder and create a Dockerfile on Solution folder

```
FROM microsoft/dotnet:sdk AS build-env
WORKDIR /app

# Copy everything else and build
COPY . ./
RUN dotnet restore MyWebApp/MyWebApp.csproj
RUN dotnet publish MyWebApp/MyWebApp.csproj -c Release -o out

# Build runtime image
FROM microsoft/dotnet:aspnetcore-runtime
WORKDIR /app
COPY --from=build-env /app/MyWebApp/out ./
ENTRYPOINT ["dotnet", "MyWebApp.dll"]
```

Build your dockerfile

```
docker build -t company/mywebapp .
```

Commit changes to the new image mywebapp
```
docker commit -m "Initial commit" -a "Junior" CONTAINER_ID company/mywebapp
```

Check if image was created
```
docker images
```
Publish the image into Docker Hub
```
docker push company/mywebapp
```

At https://hub.docker.com/u/company/ check if the image was created. Make it private if needed.

On target web server (a Linux one) pull the image you just pushed to Docker Hub
```
docker pull company/mywebapp
```

Execute your image or create a bash for running it
```
docker run -p 8080:80 --rm --name mywebapp company/mywebapp
```

Stop or remove the image if needed
```
docker stop mywebapp
docker rm mywebapp
```

To avoid using Docker Hub, backup a image, save the desired IMAGE ID as tar file
```
docker images
docker save -o mywebapp.tar IMAGEID
```

to import image from tar file on a target server
```
docker load -i mywebapp.tar
docker images
```

tag the imported image on target server
```
docker tag IMAGEID company/mywebapp
docker images
```

## Create an image based on a running container


Supposing you are already nunning a container 

```
docker run --rm -d --name kafka1 --network app-tier -e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 -e KAFKA_LISTENERS=INSIDE://:9092,OUTSIDE://:9094 -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=INSIDE:PLAINTEXT,OUTSIDE:PLAINTEXT -e KAFKA_INTER_BROKER_LISTENER_NAME=INSIDE -e KAFKA_LOG_DIRS=/opt/kafka/data/kafka -p 9092:9092 wurstmeister/kafka:latest
eaadcd70d614a0395561a1b406846c866fac476c3b71e97bee3d3cd749eced82
```

and you have made changes in its filesystem (either created or modified files, etc)
```
docker exec -it ea bash
bash-4.4# mkdir -p /opt/kafka/data/kafka
bash-4.4# mkdir -p /opt/kafka/data/zookeeper
bash-4.4# vi /opt/kafka/config/zookeeper.properties
```

and you need to generate a custom image with these modified files.
Save current container state:
```
docker commit ea kafka_base
sha256:f36f978f98e0f6921a92e09597487721614b666d8ba8a7607d5038813c4c75a9
```

Stop current container wurstmeister/kafka:latest
```
docker ps -a
CONTAINER ID        IMAGE                       COMMAND                  CREATED             STATUS              PORTS                                                      NAMES
eaadcd70d614        wurstmeister/kafka:latest   "start-kafka.sh"         5 minutes ago       Up 5 minutes        0.0.0.0:9092->9092/tcp                                     kafka1
5ad00e45011a        zookeeper:latest            "/docker-entrypoint.…"   About an hour ago   Up About an hour    0.0.0.0:2181->2181/tcp, 0.0.0.0:3888->3888/tcp, 2888/tcp   zookeeper

docker stop ea
```

Start your saved image
```
docker run --rm -d --name kafka1 --network app-tier -e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 -e KAFKA_LISTENERS=INSIDE://:9092,OUTSIDE://:9094 -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=INSIDE:PLAINTEXT,OUTSIDE:PLAINTEXT -e KAFKA_INTER_BROKER_LISTENER_NAME=INSIDE -e KAFKA_LOG_DIRS=/opt/kafka/data/kafka -p 9092:9092 kafka_base
5fc08672fc7587929616959e310852acd14dde5dd6a86e01bd0e46089f61e624
```

Check if your modifications done in container are still there
```
docker exec -it 5f bash
bash-4.4# cat /opt/kafka/config/server.properties | grep log.dirs
log.dirs=/opt/kafka/data/kafka
bash-4.4# cat /opt/kafka/config/zookeeper.properties | grep dataDir
dataDir=/opt/kafka/data/zookeeper
bash-4.4# ls /opt/kafka/data/
kafka      zookeeper
```

save your changes done in running container at any time

```
docker commit -m "fixing init script" -a "Junior" container_Id kafka_base
```

## Shutdown processes within container
Enter the container to shutdown
```
docker exec -it <container id> bash
```

install ps to see processes
```
apt-get update && apt-get install -y procps
```

Graceful shutdown
```
kill -s 15 $(pidof dotnet)
```

Forced shutdown
```
kill -s 15 $(pidof dotnet)
```

## Limit log file
```
docker run -d --restart=always -e VAR1=value --log-driver json-file --log-opt max-size=15m --log-opt max-file=5 --name yourname your/package:latest
```

## Change port of running docker container from 5000 to 5001
```
> docker ps -a
CONTAINER ID   IMAGE               COMMAND          CREATED        STATUS                     PORTS     NAMES
<id>           your/image:latest   "dotnet App.…"   4 months ago   Exited (0) 5 seconds ago             identity-server-mock

❯ docker stop <id>
<id>

❯ docker commit identity-server-mock identity-image-5001
sha256:<image id>

❯ docker images
REPOSITORY                                                                            TAG       IMAGE ID       CREATED          SIZE
identity-image-5001                                                                   latest    <image id>     17 seconds ago   479MB

❯ docker run -d -p 5001:5000 --name identity-5001 identity-image-5001
<new id>
```
