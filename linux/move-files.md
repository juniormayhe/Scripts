## Move files from subfolders to a unique destination folder

Under 2017 upper  folder, find all files within any subfolders starting with "2017..."
```
find ./2017/2017* -type f -exec mv --backup=numbered -t ./2017 {} +
```
The result:
```
Source files                 Destination files
-------------                ------------------ 
root                         root
|___ 2017                    |___ 2017/*
     |___ 2017-01-01/*          |__ 2017-01-01/(empty)
     |___ 2017-02-27/*          |___ 2017-02-27/(empty)
     |___ 2017.../*             |___ 2017.../(empty)
```

To delete the empty folders, from the root folder
```
find . -type d -empty -delete
```
