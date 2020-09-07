docker-compose up -d

```yaml
version: '3.5'

services:
  kafka:
    image: johnnypark/kafka-zookeeper
    ports:
      - "2181:2181"  
      - "9092:9092"
    environment:
      - "ADVERTISED_HOST=127.0.0.1"
      - "NUM_PARTITIONS=10"
    restart: always
    networks:
      - kafka-network
networks: 
    kafka-network:
      driver: bridge
```
