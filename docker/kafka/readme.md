docker-compose up -d

```yaml
version: '3'

services:
  kafka:
    image: johnnypark/kafka-zookeeper
    ports:
      - "2181-2181"  
      - "9092-9092"
    networks:
      - kafka-network
    environment:
      ADVERTISED_HOST: 127.0.0.1
      NUM_PARTITIONS: 10
networks: 
    kafka-network:
      driver: bridge
```
