# Prometheus

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

## Run Prometheus on docker
```powershell
docker run --name prometheus --rm -d -p 9090:9090 -v C:\wander\curso-prometheus\prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus
```

## Check if Prometheus is up and running

- To check prometheus own metrics http://localhost:9090/metrics
- To check prometheus current configuration visit http://localhost:9090/config
- To check prometheus `scrape_duration_seconds` visit http://localhost:9090/graph?g0.expr=scrape_duration_seconds&g0.tab=0&g0.stacked=0&g0.range_input=15m

