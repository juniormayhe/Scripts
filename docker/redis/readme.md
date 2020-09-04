docker-compose up

```yaml
version: '3'

services:
  redis:
    image: redis
    ports:
      - "6379-6379"      
    networks:
      - redis-network
   
networks: 
    redis-network:
      driver: bridge
```
