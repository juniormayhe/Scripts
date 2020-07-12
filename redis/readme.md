# Redis

## Run latest redis image
```
docker run --rm -d -p 6379:6379/tcp --name redis redis:latest
```

## Preview redis data

If you have nodejs installed, install redis commander:
```
npm install -g redis-commander
redis-commander
```
Execute redis commander

browse localhost:8081 to manage redis at localhost:6379
