#!/bin/bash
PROJECT_NAME=mean-exercises
URL=https://github.com/juniormayhe/mean-exercises.git
cd /$PROJECT_NAME
git init
git add .
git config --global user.email "juniormayhe@gmail.com"
git config --global user.name "Wanderley Mayhe Junior"
git commit -m "Initial commit"
printf $'Setting local repository origin to be pushed to $URL...'
git remote add origin $URL
printf "Pusing local commits to remote master..."
git pull origin master
git push origin master -f
