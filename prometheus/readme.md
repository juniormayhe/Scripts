# Prometheus

Prometheus is both pull-based and push-based metrics collector. 

In pull-based collection, prometheus fetches metric data from applications that have implemented metrics collection at http://machine-name:9090/metrics. When we cannot implement metrics collection by changing applications source code, we must use exporters. Exporters can collect metrics from SQL Server and other 3rd party tools that we cannot change source code. Prometheus will then fetch metric data from exporters.

In push-based collection, applications send metric data directly to prometheus. Push-based is common for short-lived applications because there is no reason for them to be pulled by prometheus every N seconds since they can go offline anyime. A Push Gateway aggregates metrics sent by short-lived applications and prometheus pull them from this gateway.

Prometheus pushes alerts to Alert manager send notifications.

## Create your local prometheus configuration file

prometheus.yaml

```yaml
global:
  scrape_interval: 30s
  scrape_timeout: 10s
  evaluation_interval: 15s
#alerting:
#  alertmanagers:
#  - follow_redirects: true
#    scheme: http
#    timeout: 10s
#    api_version: v2
#    static_configs:
#    - targets: []
scrape_configs:
- job_name: prometheus
  honor_timestamps: true
  scrape_interval: 15s
  scrape_timeout: 10s
  metrics_path: /metrics
  scheme: http
  follow_redirects: true
  static_configs:
  - targets:
    - localhost:9090
```
After changing configuration stop or restart container
```powershell
docker container restart prometheus
```

## Run Prometheus on docker
```powershell
docker run --name prometheus --rm -d -p 9090:9090 -v C:\wander\curso-prometheus\prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus
```

## Check if Prometheus is up and running

- To check prometheus own metrics http://localhost:9090/metrics
- To check prometheus current configuration visit http://localhost:9090/config
- To check prometheus `scrape_duration_seconds` visit http://localhost:9090/graph?g0.expr=scrape_duration_seconds&g0.tab=0&g0.stacked=0&g0.range_input=15m

## Visualize metrics in prometheus

Some PromQL examples for visualizing metrics data

1) Counter growth rate: `increase(<counter name>[<start time interval until now>])`

Shows growth rate in the last minute for myapp_requests_counter:
```promql
increase(myapp_requests_counter[1m])
```

2) Sum all counters growth rates: `sum(increase(<counter name>[<start time interval until now>]))`

Sum all counter series (different promql labels) in the last minute for myapp_requests_counter:
```promql
sum(increase(myapp_requests_counter[1m]))
```

3) Filter counter growth rate: `increase(<counter name>{<label name>="<value>"}[<start time interval until now>])`

Get specific counter (promql label) in the last minute for myapp_requests_counter:
```promql
increase(myapp_requests_counter{statusCode="200"}[1m])
```
the labels must have been set by instrumentation with promql client, like so:
```node
// install express
// npm install --save express
var express = require('express');
var app = express();

// install prometheus client 
// npm install --save prom-client
var client = require('prom-client');

const counter = new client.Counter({
    name: 'myapp_requests_counter',
    help: 'GET Requests counter',
    labelNames: ['statusCode']
});

app.get('/', function (req, res) {
    counter.labels('200').inc(); // adds statusCode label
    
    res.send('hello');
    //counter.inc();
});
```
