#!/bin/bash
clear
PROJECT_NAME=mean-exercises
echo "******************************************"
echo "Preparing environment for MEAN project on Fedora..."
echo "******************************************"

printf $"Creating $PROJECT_NAME folders..."
mkdir -p /$PROJECT_NAME
mkdir -p /$PROJECT_NAME/shell
mkdir -p /$PROJECT_NAME/data/db
mkdir -p /$PROJECT_NAME/data/log

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

printf "Preparing npm for $PROJECT_NAME..."
cd /$PROJECT_NAME/
npm init
npm install mongodb --save
npm install mongoose --save
npm install mocha --save
npm install gulp --save
npm install gulp-mocha --save
git init

echo "Running mongod server..."
echo "mongod --dbpath /$PROJECT_NAME/data/db --shutdown"  > /$PROJECT_NAME/shell/stop-database.sh
chmod +x /$PROJECT_NAME/shell/stop-database.sh
echo "mongod --dbpath /$PROJECT_NAME/data/db/ --logpath /$PROJECT_NAME/data/log/$PROJECT_NAME.log --fork" > /$PROJECT_NAME/shell/start-database.sh
chmod +x /$PROJECT_NAME/shell/start-database.sh
/$PROJECT_NAME/shell/start-database.sh

echo $"Your folder is /$PROJECT_NAME"