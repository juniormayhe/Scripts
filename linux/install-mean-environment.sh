#!/bin/bash
echo "******************************************"
echo "Preparing environment for MEAN project on Fedora..."
echo "******************************************"

echo "Creating your-project-name folders..."
mkdir -p /your-project-name
mkdir -p /your-project-name/shell
mkdir -p /your-project-name/data/db
mkdir -p /your-project-name/data/log

echo "Installing packages in docker..."
dnf install curl -y
dnf install wget -y
dnf install nodejs -y
dnf install git -y
dnf install vim -y

echo "Downloading mongodb 3.4.2..."
wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.4.2.tgz

echo "Decompressing mongodb 3.4.2..."
tar -zxvf mongodb-linux-x86_64-3.4.2.tgz

echo "Moving to  mongodb to /opt..."
mv -f mongodb-linux-x86_64-3.4.2 /opt/

echo "Creating symlinks for mongod server and mongo cli..."
ln -s /opt/mongodb-linux-x86_64-3.4.2/bin/mongod /usr/local/bin/mongod
ln -s /opt/mongodb-linux-x86_64-3.4.2/bin/mongo /usr/local/bin/mongo

echo "Preparing npm for your-project-name..."
cd /your-project-name/
npm init
npm install mongodb --save
npm install mongoose --save
npm install mocha --save
npm install gulp --save
npm install gulp-mocha --save
git init

echo "Running mongod server..."
echo "mongod --dbpath /your-project-name/data/db --shutdown"  > /your-project-name/shell/stop-database.sh
chmod +x /your-project-name/shell/stop-database.sh
echo "mongod --dbpath /your-project-name/data/db/ --logpath /your-project-name/data/log/your-project-name.log --fork" > /your-project-name/shell/start-database.sh
chmod +x /your-project-name/shell/start-database.sh
/your-project-name/shell/start-database.sh