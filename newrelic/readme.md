# NewRelic

## GraphQL query format

```
curl https://api.newrelic.com/graphql \
  -H 'Content-Type: application/json' \
  -H 'API-Key: NRAK-*****************' \
  --data-binary '{"query":"{\n  actor {\n    nrql(query: \"SELECT count(*) FROM Transaction facet appName limit 1000\", accounts: <your account id>) {\n      nrql\n      results\n    }\n  }\n}\n", "variables":""}'
```

## Availability
```
SELECT percentage(count(), WHERE response.status not like '5%') as 'SLOCurrentPercentage',  
count() as 'SLOTargetTotalTransactions', 
filter(count(*), WHERE response.status like '5%') as 'SLOErrorBudgetBurned'
FROM Transaction
WHERE appName='MyAppName' 
AND name = 'WebTransaction/WebService/MyApp.DoSomething'
SINCE 2 HOURS ago
```

## Latency timeseries
```
SELECT percentile(duration,95), 1.24 as targetSLOInSeconds FROM Transaction  
WHERE appName = 'MyApp' 
AND request.method ='GET' 
AND name = 'WebTransaction/MVC/ControllerName/ControllerMethod/{id}' 
SINCE 2 HOUR AGO TIMESERIES 15 MINUTES
```

## Error budget last 2 hours
```
SELECT percentile(OrderCreationLatency, 95), 30 as 'targetSLOInSeconds' 
FROM Transaction 
WHERE appName = 'myApp' 
AND name = 'OtherTransaction/Custom/MyCustomTransaction' 
SINCE 2 hours ago TIMESERIES 15 minutes
```

## Total transactions by request method (post, get, etc)
```
SELECT COUNT(name) FROM Transaction
FACET request.method
WHERE appName = 'myApp'
and name = 'WebTransaction/MVC/MyController/MyMethod/{id}'
LIMIT 5 SINCE 1 DAY AGO
```

## Client user agents 
```
SELECT  `request.headers.user-agent`, name from Transaction 
WHERE appName = 'myApp' 
SINCE 6 HOURS AGO LIMIT 10
```

## Table scheme
```
SELECT KEYSET()  FROM Transaction 
WHERE appName = 'myApp' 
AND name = 'WebTransaction/WebAPI/MyAPI/MyMethod' 
SINCE 1 day AGO
```

## Transactions of a single trace id / distributed tracing
```
SELECT * FROM Span WHERE traceId = (SELECT traceId FROM Transaction  
WHERE appName = 'myApp' and request.method ='POST' 
and sampled = true SINCE 2 HOURS AGO LIMIT 1) 
SINCE 2 HOURS AGO LIMIT 100
```
