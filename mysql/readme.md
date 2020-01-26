# Full Backup with mysqldump 
```
mysqldump mysql > mysql-$( date '+%Y-%m-%d_%H-%M-%S' ).sql --user='root' --password='pass' 
mysqldump information_schema > information_schema-$( date '+%Y-%m-%d_%H-%M-%S' ).sql --user='root' --password='pass' --lock-tables=false 
mysqldump performance_schema > performance_schema-$( date '+%Y-%m-%d_%H-%M-%S' ).sql --user='root' --password='pass' --lock-tables=false 
```

# Restore database

## Create a database
```
mysqladmin create mydb --user='root' --password='pass'  
```

## Import database
```
mysql --user='root' --password='pass' mydb < source-backup-file.sql  
MYSQL_PWD='mypass' mysql --user='root' mydb < /var/tmp/backup-file.sql 
```

## Create user
```
mysql –u root -p 

use mysql; 

CREATE USER 'myuser@'localhost' IDENTIFIED BY 'pass'; 

GRANT ALL PRIVILEGES ON myuser.* TO 'myuser'@'localhost'; 
```
 
## Show databases
```
mysql –u root -p 

use mysql; 

show databases; 
```

## Show table columns
```
mysql –u root -p 

use mysql; 

show columns from mytable; 
```
