
docker pull nginx:alpine
docker run --name alpina -it -P nginx:alpine /bin/sh

echo "To stop alpine"
echo "docker stop alpina"

echo "To reattach alpine"
echo "docker start -a alpina -i"
echo "or"
echo "docker alpina"

