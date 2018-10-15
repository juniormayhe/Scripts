!#/bin/bash
echo "Solves git pull error: cannot lock ref 'refs/remotes/origin/features/...':"
git gc --prune=now
git remote prune origin
echo "now you can use git pull"
