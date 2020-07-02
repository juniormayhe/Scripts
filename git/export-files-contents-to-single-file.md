# Export all remote file contents to a single text file

```bash
#!/bin/sh
# using git bash or similar:
# 1) generate a rsa key ssh-keygen -o -t rsa -b 4096 -C "your-name@email.com"
# 2) copy cat ~/.ssh/id_rsa.pub 
# 3) paste it in https://github.com/settings/keys, so git archive works with ssh
# 4) export output of all files from remote repos into dump folder
# ./merge-all-remote-files-content >dump/output.txt 2>/dev/null 

get_content(){
  # get all contents of .yaml files from remote git repositories
  git -c protocol.version=2 archive --remote $1 master *.yaml 2>/dev/null | tar -O -xf - 2>/dev/null | tr -d '\0'
}
export -f get_content

output_remote_repository_content() {
  local NL=$'\n';
  echo "#on $1${NL}$(get_content $1)${NL}";
}
export -f output_remote_repository_content

# search in your your-local-path all files that starts with "repository: https://www.github.com"
grep -hr "^repository: https://gitlab.fftech.info" your-local-path | awk '{ print $2 }' | sort | uniq | sed 's|https://\(www.github.com\)/|git@\1:|' | xargs -P0 -I {} bash -c "output_remote_repository_content {}"
```
