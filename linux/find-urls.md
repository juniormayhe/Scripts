# Find urls

## Grep all urls from file
```
$ grep -Eo '(http|https)://[^/"]+' appsettings.json

https://svc-authbo.info
http://10.61.45.18:9142
http://svc-inventory.info
https://svc-merchant.info:9151
...
```

## Grep all ip and port from file
```
$ grep -Eo '([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})\:?([0-9]{1,5})?' appsettings.json

10.61.45.18:9142
129.0.0.1:123
```
