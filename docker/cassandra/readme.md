docker-compose up docker-compose.yml

```yaml
version: '3.5'

services:
  cassandra:
    image: cassandra:latest
    container_name: cassandra
    ports:
      - "9042:9042"
      - "9160:9160"
      - "7001:7001"
      - "7000:7000"
      - "7199:7199"
    environment:
      - "MAX_HEAP_SIZE=256M"
      - "HEAP_NEWSIZE=128M"
    restart: always
    volumes:
      - C:\temp\cassandra_data:/var/lib/cassandra
```
