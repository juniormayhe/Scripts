# Backup full do site com tar 

```
tar -cvpzf nome-do-site.tar.gz --exclude=nome-do-site.tar.gz --one-file-system /var/www/html/  
```

c - creates a new tar file

v - print included file names

p - keep permissions attributes

z - compress data

f - name tar file
