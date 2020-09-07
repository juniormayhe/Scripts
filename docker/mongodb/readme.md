# mongodb for Docker on Windows

```
version: '3.5'

services:
  mongo:
    image: mongo:latest
    environment:
      - "MAX_HEAP_SIZE=256M"
      #- "MONGO_INITDB_DATABASE=root"
      #- "MONGO_INITDB_ROOT_USERNAME=root"
      #- "MONGO_INITDB_ROOT_PASSWORD=MongoDB2019!"
    ports:
      - "27017:27017"
      - "27018:27018"
      - "27019:27019"
    #volumes:
    #  - C:\temp\mongodb_data:/data/db
    #  - C:\temp\mongodb_log:/var/log/mongodb/
    networks:
      - mongo-network

networks: 
    mongo-network:
      driver: bridge
```

then
```
docker-compose up -d
```
