
# Linux scripts

## Docker commands for Ubuntu 

Main docker commands: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04

## Publishing docker image on Docker Hub

Create an account at https://hub.docker.com/u/taxindividual/

Setup docker login at CLI
```
docker login
```

Create your NET Core app with a dockerfile such as 

```
FROM microsoft/dotnet:sdk AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM microsoft/dotnet:aspnetcore-runtime
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "MyWebApp.dll"]
```

Build your dockerfile

```
docker build -t mywebapp .
```

Commit changes to the new image mywebapp
```
docker commit -m "Initial commit" -a "Junior" CONTAINER_ID company/mywebapp
```

Check if image was created
```
docker images
```
Publish the image into Docker Hub
```
docker push company/mywebapp
```

At https://hub.docker.com/u/company/ check if the image was created. Make it private if needed.

On target web server (a Linux one) pull the image you just pushed to Docker Hub
```
docker pull company/mywebapp
```

Execute your image or create a bash for running it
```
docker run -p 8080:80 --rm --name mywebapp company/mywebapp
```

Stop or remove the image if needed
```
docker stop mywebapp
docker rm mywebapp
```