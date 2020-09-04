docker-compose up docker-compose.yml

```yaml
version: '3'

services:
  cassandra:
    image: cassandra
    ports:
      - "7000-7000"
      - "7001-7001"
      - "7199-7199"
      - "9042-9042"
      - "9160-9160"
    volumes:
      - data-volume:/data/db
      
    networks:
      - cassandra-network

volumes:
  data-volume:
    
networks: 
    cassandra-network:
      driver: bridge
```
