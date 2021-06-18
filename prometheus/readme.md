# Prometheus

Prometheus is both pull-based and push-based metrics collector. 

In pull-based collection, prometheus fetches metric data from applications that have implemented metrics collection at http://machine-name:9090/metrics. When we cannot implement metrics collection by changing applications 3rd party applications source code, we must use exporters. Exporters can collect metrics from hardware applications, operating systems, databases (MySQL, MongoDB, Redis, SQL Server, etc), collaboration tools (jira, confluence, jenkins), messaging (kafka, rabbitmq), http (apache, haproxy, ningx), 3rd party apis (AWS, cloudflare, digital ocean, docker, github, monitoring systems (akamai, aws cloudwatch, graphite, influxdb). Prometheus will then fetch metric data from exporters.

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

## Exporters

- for linux machines https://github.com/prometheus/node_exporter
- for windows machines https://github.com/prometheus-community/windows_exporter

### Windows exporter

- Download the release https://github.com/prometheus-community/windows_exporter/releases
- Visit http://localhost:9182/metrics

## PromQL

### Counter queries

- Instant vector or get current counter for current timestamp `<counter name>`. This will plot a graph where the counter always grow which doesn't make much sense. In grafana it might be more useful to plot this counter in a stats or gauge graph.
- Growth rate per second in the last minute `rate(<counter name>[1m])`. With rate we avoid showing a counter continuously growing in graph. A range vector is needed, in this case 1 minute or [1m]. And the result or rate function is an instant vector. Each label will hold a single value.
- Growth rate per minute in the last minute `rate(<counter name>[1m]) * 60`
- How much the counter increased or grew in the last minute `increase(<counter name>[1m])` this will return a similar result as `rate(<counter name>[1m]) * 60` because both functions return the growth in the last minute.

### Gauge queries

- Instant vector or get current counter for current timestamp `<counter name>`.

### Summary queries

- Instant vector or get current summary for current timestamp `<counter name>`. This will list all quantile values by labels: instance, job and le.

the percentiles buckets are set in instrumentation with promql client, like so:
```node
// install express
// npm install --save express
var express = require('express');
var app = express();

// install prometheus client 
// npm install --save prom-client
var client = require('prom-client');

const summary = new client.Summary({
    name: 'myapp_summary_response_time',
    help: 'myapp_Summary response time in seconds',
    percentiles: [0.5, 0.9, 0.99] //the fastest to the slowest response time φ-quantiles, where 0 ≤ φ ≤ 1, 0.5 is the 50th percentile or median
});

app.get('/', function (req, res) {
    summary.observe(Math.random()); // simulate 0 to 1
    
    res.send('hello');
});
```

### Histogram queries

- Get total registered in all buckets for current timestamp `<histogram name>_bucket`.
- Get total registered in a specific bucket for current timestamp `<histogram name>_bucket{le="<value>"}` where value relates to the nature of the data you instrumented (elapsed time, temperature, etc). If the values are response time in seconds we could get the amount of response times that took up to 300 ms with `<histogram name>_bucket{le="0.3"}`. Since the amount of response times acts like a counter and grow over time for the 300ms bucket we need to use rate or increase and use a range vector `increase(<histogram name>_bucket{le="0.3"})[1m]`
- Calculate the 90th percentile of response time over (aka 90% of the fulfilled requests) the last 10 minutes `histogram_quantile( 0.9, rate(myapp_summary_response_time[10m]) )`. To calculate or infer the percentile (e.g. 0.9) is useful when the buckets have a different set of labels (0.005, 0.01, 0.025, 0.5, ...) 
- Aggregate with sum the previous query by job name (all instances or ip addresses will be consolidated). `histogram_quantile( 0.9, sum(rate(myapp_summary_response_time[10m])) by (job, le) )`. The le label is required when aggregating the desired percentile.
- Get the total of requests for all buckets `<histogram name>_count`. This is the same of `<histogram name>_bucket{le="+Inf"}`.
- Get the growth rate of the total of requests over the last minute `increase(<histogram name>_count[1m])`. The `<histogram name>_count` is the same of `<histogram name>_bucket{le="+Inf"}`.
- We can run math operatores when all histograms have the same labels. An example is trying to calculate the percentage of requests that took 300 ms `increase(<histogram name>_bucket{le=0.3}[1m]) / increase(<histogram name>_count[1m])`. The first part has a label le=0.3 that does not exist in the second part of the formula expression. One way to circumvent this is to sum all series to return no label `sum(increase(<histogram name>_bucket{le=0.3}[1m])) / sum(increase(<histogram name>_count[1m]))`. This wil plot the % of requests that took up to 300ms.

the value buckets are set in instrumentation with promql client, like so:
```node
// install express
// npm install --save express
var express = require('express');
var app = express();

// install prometheus client 
// npm install --save prom-client
var client = require('prom-client');

const summary = new client.Summary({
    name: 'myapp_summary_response_time',
    help: 'myapp_Summary response time in seconds',
    percentiles: [0.5, 0.9, 0.99] //the fastest to the slowest response time φ-quantiles, where 0 ≤ φ ≤ 1, 0.5 is the 50th percentile or median
});

const histogram = new client.Histogram({
    name: 'myapp_response_time',
    help: 'Response time in seconds',
    buckets: [0.1, 0.2, 0.3, 0.4, 0.5] // if we comment this line, prom-client will auto generate buckets lower or equal le=0.005 sec, 0.01 sec, 0.025 sec, 0.05 sec, 1 sec, 2.5 sec, 5 sec, 10 sec and +Inf which are useful for measuring http APIs
});

app.get('/', function (req, res) {
    histogram.observe(Math.random()); // simulate 0 to 1
    
    res.send('hello');
});
```

