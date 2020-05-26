# mongodb for Docker on Windows

```
version: '3'

services:
  mongo:
    image: mongo
    #environment:
      #MONGO_INITDB_ROOT_USERNAME: root
      #MONGO_INITDB_ROOT_PASSWORD: MongoDB2019!
    ports:
      - "27017-27019:27017-27019"
    volumes:
      - data-volume:/data/db
      
    networks:
      - mongo-network

volumes:
  data-volume:
    
networks: 
    mongo-network:
      driver: bridge
```

then
```
docker-compose up -d
```
