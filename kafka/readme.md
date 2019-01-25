## Execute Kafka via docker run

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
