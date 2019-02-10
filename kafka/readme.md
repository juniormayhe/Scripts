# Kafka in docker 

## Windows

On Windows ensure Hyper V is installed and **Hyper-V Virtual Machine Management** is running.

Switch to Linux Containers on Docker.


## Pull official immages

```
docker pull zookeeper

docker pull wurstmeister/kafka
```

## Create a network for linux containers

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
## Using Kafka in docker 

After configuring dirs, running zookeeper and kafka

```
docker network create app-tier --driver bridge

docker run --rm -d --name zookeeper --network app-tier -p 2181:2181 -p 3888:3888 zookeeper:latest

docker run --rm -d --name kafka1 --network app-tier -e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 -e KAFKA_LISTENERS=INSIDE://:9092,OUTSIDE://:9094 -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=INSIDE:PLAINTEXT,OUTSIDE:PLAINTEXT -e KAFKA_INTER_BROKER_LISTENER_NAME=INSIDE -e KAFKA_LOG_DIRS=/opt/kafka/data/kafka -p 9092:9092 kafka_base
```

### Create, list and delete topics

Now that you  have one kafka broker (server) running, you can use replication-factor 1. Notice that zookeeper is a known host within docker network and you may replace it by an IP or another hostname if needed. 

```
kafka-topics.sh --zookeeper zookeeper:2181 --topic first_topic --create --partitions 3 --replication-factor 1
```

Check if topic is created
```
kafka-topics.sh --zookeeper zookeeper:2181 --list
first_topic
second_topic
```

How many partitions topic has?
```
kafka-topics.sh --zookeeper zookeeper:2181 --topic first_topic --describe
Topic:first_topic       PartitionCount:3        ReplicationFactor:1     Configs:
        Topic: first_topic      Partition: 0    Leader: 1002    Replicas: 1002  Isr: 1002
        Topic: first_topic      Partition: 1    Leader: 1002    Replicas: 1002  Isr: 1002
        Topic: first_topic      Partition: 2    Leader: 1002    Replicas: 1002  Isr: 1002
```

Delete a topic
```
kafka-topics.sh --zookeeper zookeeper:2181 --topic second_topic --delete
```

### Produce message

Produce a message to topic and press Ctrl C after entering your message
```
kafka-console-producer.sh --broker-list localhost:9092 --topic first_topic
```

Produce a message to topic and guarantee that all brokers / servers receive it
```
kafka-console-producer.sh --broker-list localhost:9092 --topic first_topic --producer-property acks=all
```

Messages will be displayed by consumer if it has been started before Producer.

### Consume message

Consume realtime messages if producer is already running
```
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic first_topic
```

Consuming unread messages (within 7 days). If offset has been commited to kafka (messages already read from beginning by a group of consumers), this  shows an empty list.
```
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic first_topic --from-beginning
```

To share the load by setting consumer group for an application to make messages be split among partitions of all consumers.

So if you have 3 consumers running, all messages receive will be split into 3 different partitions
```
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic first_topic --group my-first-application
```

If all group of consumers go down and messages are being produced, when a consumer goes back online, messages will be read from next unread offset of a partition.

## Managing group of consumers

Show created consumer groups
```
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list
```

Show details of a consumer group. LAG 0 indicates that all data has been read, otherwise it has unread messages.
```
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-first-application
Consumer group 'my-first-application' has no active members.

TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID     HOST            CLIENT-ID
first_topic     0          4               7               3               -               -               -
first_topic     1          3               6               3               -               -               -
first_topic     2          5               8               3               -               -               -
```


## Troubleshotting

### Kafka is not running

#### Network error

If kafka cannot start due to `Error starting userland proxy: mkdir /port/tcp:0.0.0.0:9092:tcp:172.19.0.3:9092: input/output error`, restart docker to free 9092 port or check if 9092 port is busy.

If kafka is still not working, check log.dirs in /opt/kafka/config/server.properties 
```
docker exec -it containerId bash
/opt/kafka/config/server.properties
```

#### Kafka container starts but kafka_topics.sh says there are 0 brokers

Check if kafka-start.sh starts zookeeper and kafka in docker.
```
docker exec -it containerId bash
vi /usr/bin/start-kafka.sh
```

Add these commands to add at the end of start-kafka.sh:
```
##maybe we do not need to start zookeeper-srever within kafka container...
nohup exec "$KAFKA_HOME/bin/zookeeper-server-start.sh" "$KAFKA_HOME/config/zookeeper.properties" &>/dev/null &

exec "$KAFKA_HOME/bin/kafka-server-start.sh" "$KAFKA_HOME/config/server.properties"
```

Commit changes and run again kafka_base
```
docker commit -m "fixing init script" -a "Junior" 29 kafka_base
```

Stop the old container and docker run kafka_base again

```
docker ps
docker stop containerId

docker run --rm -d --name kafka1 --network app-tier -e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 -e KAFKA_LISTENERS=INSIDE://:9092,OUTSIDE://:9094 -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=INSIDE:PLAINTEXT,OUTSIDE:PLAINTEXT -e KAFKA_INTER_BROKER_LISTENER_NAME=INSIDE -e KAFKA_LOG_DIRS=/opt/kafka/data/kafka -p 9092:9092 kafka_base
```

try to run kafka_topics again
```
docker exec -it containerId bash

$ kafka-topics.sh --zookeeper 127.0.0.1:2181 --topic first_topic --create --partitions 3 --replication-factor 1
```
