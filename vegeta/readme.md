# Vegeta

Load test ignore ssl errors, use `-insecure`:
```
PS C:\Users\wanderley.junior> docker run --rm -i peterevans/vegeta sh -c "echo 'GET https://10.129.34.70:11000/healthcheck' | vegeta attack -insecure -rate=100 -duration=60s | tee results.bin | vegeta report"

Requests      [total, rate, throughput]         6000, 100.02, 99.85
Duration      [total, attack, wait]             1m0s, 59.99s, 98.451ms
Latencies     [min, mean, 50, 90, 95, 99, max]  51.362ms, 119.329ms, 103.939ms, 159.802ms, 241.906ms, 386.49ms, 1.284s
Bytes In      [total, mean]                     0, 0.00
Bytes Out     [total, mean]                     0, 0.00
Success       [ratio]                           100.00%
Status Codes  [code:count]                      200:6000
```
