# Kafka in docker 

## Windows

On Windows ensure Hyper V is installed and **Hyper-V Virtual Machine Management** is running.

Switch to Linux Containers on Docker.


## Pull official immages

```
docker pull zookeeper

docker pull wurstmeister/kafka
```

## Create a nework for linux containers

```
docker network create app-tier --driver bridge
```

## Start images

```
docker run --rm -d --name zookeeper --network app-tier -p 2181:2181 -p 3888:3888 zookeeper:latest

docker run --rm -d --name kafka1 --network app-tier -e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 -e KAFKA_LISTENERS=INSIDE://:9092,OUTSIDE://:9094 -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=INSIDE:PLAINTEXT,OUTSIDE:PLAINTEXT -e KAFKA_INTER_BROKER_LISTENER_NAME=INSIDE -p 9092:9092 wurstmeister/kafka:latest
```

More on environment variables: https://hub.docker.com/r/wurstmeister/kafka/

## Attaching shell to edit files within containers

To access container terminal try to  figure the container id:

```
docker ps
```

Execute desired container

```
docker exec -it CONTAINER_ID bash
```

Or if you are using visual Code with Docker extension and gitbash, on Settings, set Docker > Attach Shell Command: Linux Container to
```
bash -c "/bin/bash || /bin/sh"
```
and choose Attach Shell at Docker extension.


## Saving container changes to a new image juniormayhe/kafka

```
docker commit container_id juniormayhe/kafka
```

## Execute Kafka via docker run with java

```
C:\WINDOWS\system32>docker run -p 9099:9092 -e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 -e KAFKA_ADVERTISED_HOST_NAME=localhost -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=127.0.0.1 -Dcom.sun.management.jmxremote.rmi.port=1099" -e JMX_PORT=1099 --name mykafka kafka
```

## Execute Kafka via docker compose with yml

```
C:\WINDOWS\system32>docker-compose -f your-kafka.yml up -d
```

your-kafka.yml content
```
Untitled 
version: '3.5'

services:
 kafka:
  container_name: mykafka
  image: wurstmeister/kafka
  ports:
   - "9092:9092"
  environment:
   KAFKA_ADVERTISED_HOST_NAME: localhost
   KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
   KAFKA_JMX_OPTS: "-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=127.0.0.1 -Dcom.sun.management.jmxremote.rmi.port=1099"
   JMX_PORT: 1099
  volumes:
   - C:\@work\docker_volume\docker.sock:/var/run/docker.sock
```
