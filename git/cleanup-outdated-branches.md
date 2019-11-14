# Cleaning outdated local branches

At first, list all local branches:
```
git branch
```

We need to know what branches are already merged in “master” and can be easily removed:
```
git checkout master
git branch --merged
```

Now, remove all outdated branches with:
```
git branch -d old-merged-feature
```

Next, decide what to do with not merged branches:
```
git branch --no-merged
```

If some of them is just abandoned stuff that you don’t need anymore, remove it with “-D” option:
```
git branch -D <old-branch-name>
```

# Cleaning outdated remote branches

At first, we can find branches which are already merged in “master”:
```
git checkout master
for branch in `git branch -r --merged | grep -v HEAD`; do echo -e `git show --format="%ci %cr %an" $branch | head -n 1` \\t$branch; done | sort -r
```

Now, you can delete remote branches, and ask other authors to clean-up theirs:
```
git push origin --delete <branch-name>
```

To remove outdated remote branches not merged
```
for branch in `git branch -r --no-merged | grep -v HEAD`; do echo -e `git show --format="%ci %cr %an" $branch | head -n 1` \\t$branch; done | sort -r
git push origin --delete <branch-name>
```
