# Connect to github as local user

Useful when you already have a global user configured.

From git bash, generate private and public ssh rsa key
```
ssh-keygen -t rsa -b 4096 -C "myemail@domain.com" -f /c/Users/wanderley.junior/.ssh/github_projectname_rsa
```

Create a project repository in github at https://github.com/new

Copy ssh rsa public key and paste it at Github Deploy keys https://github.com/juniormayhe/ProjectName/settings/keys
```
cat /c/Users/wanderley.junior/.ssh/github_projectname_rsa.pub
```

Ensure ssh agent is running
```
eval $(ssh-agent -s)
```

Add private key into ssh folder
```
ssh-add /c/Users/wanderley.junior/.ssh/github_projectname_rsa
```

Initialize git at project folder and add remote
```
git init
git remote add origin git@github.com:juniormayhe/ProjectName.git
```

Configure git user for local
```
git config --local -l
git config --local user.email "juniormayhe@gmail.com"
git config --local user.name "Junior Mayhe"
```

# Upload files from local git to github
```
git add . && git commit -m "readme added" && git push origin master
```

# Remove local branches not in remote
```
git branch --merged origin/master | grep -v master | xargs git branch -d
```
