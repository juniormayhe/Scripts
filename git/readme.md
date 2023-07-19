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
git fetch -p && git branch --merged origin/master | grep -v master | xargs git branch -d
```

# Interactive rebase to avoid Push failed gitiquette validations

```sh
#!/bin/bash

# Function to handle errors
function handle_error {
  echo "Error: Command failed. Performing recovery steps..."
  git rebase --abort
  git reset --hard
  git reset --hard "$current_branch"
  echo "Recovery steps executed successfully."
  exit 1
}

# Get the current branch name
current_branch=$(git symbolic-ref --short HEAD)

# If an argument is provided, use it as the current branch
if [ -n "$1" ]; then
  current_branch="$1"
  git checkout "$current_branch"
fi

# Run the commands in the specified sequence without confirmation
echo "fetching..."
git fetch || handle_error

echo "pulling..."
git pull || handle_error

echo "fetching master..."
git fetch origin master:master || handle_error

echo "interactive rebasing..."
git rebase -i origin/master

echo "continue rebasing..."
git rebase --continue

echo "push changes..."
git push -f origin "$current_branch" || handle_error

echo "Script executed successfully."
```
