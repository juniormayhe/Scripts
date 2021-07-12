# Bombardier

Ignore certificates, pass headers and make a 3000 posts using 10 connections with timeout of 40s

```
$ bombardier -k -H "Content-Type: application/json" -H "Authorization: Bearer ey" -t 40s -m POST -c 10 -n 3000 https://10.129.35.87:11000/v1/search -b "{'tenantId':10000}"
```

Output with 200 status code
```
Bombarding https://10.129.35.87:11000/v1/search with 3000 request(s) using 10 connection(s)
 3000 / 3000 [=========================================================================================================================================================================================] 100.00% 8/s 5m36s
Done!
Statistics        Avg      Stdev        Max
  Reqs/sec         8.98      30.97     999.65
  Latency         1.12s   447.30ms      6.49s
  HTTP codes:
    1xx - 0, 2xx - 3000, 3xx - 0, 4xx - 0, 5xx - 0
    others - 0
  Throughput:    21.87KB/s
```

## Run from docker container

```
docker run -it --rm --name bombardier alpine/bombardier -k -H 'Content-Type: application/json' -m GET -c 200 -n 30 -l https://<ip>:<port>/api
```
