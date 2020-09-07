docker-compose up

```yaml
version: '3.5'

services:
  redis:
    image: redis:latest
    ports:
      - "6379:6379"      
    networks:
      - redis-network
   
networks: 
    redis-network:
      driver: bridge
```
