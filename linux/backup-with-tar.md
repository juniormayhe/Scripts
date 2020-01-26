# Full Backup with tar 

```
tar -cvpzf nome-do-site.tar.gz --exclude=nome-do-site.tar.gz --one-file-system /var/www/html/  
```

c - creates a new tar file

v - print included file names

p - keep permissions attributes

z - compress data

f - name tar file

## Backup with date in filename to tmp folder
```
tar -cvpzf /tmp/mysite-$( date '+%Y-%m-%d_%H-%M' ).tar.gz --exclude-vcs /var/www/html/ 
```

## View files in tar
```
tar -tvf mysite.tar.gz
```

## View if file has a file in specific folder
```
tar -tf mysite.tar.gz wordpress/wp-config-sample.php 
```

## View if file has a file in any folder
```
tar -tf mysite.tar.gz */readme.txt
```

## Backup do banco com mysqldump 
## Uncompress tar files
```
tar -xvpzf mysite.tar.gz -C /var/www/html/ --numeric-owner 
```
