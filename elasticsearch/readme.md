# Elasticsearch

Filters for kibana dashboard:

## Contains

Field `my-message` contains a the string `Failed` value
```
{
  "query": {
    "query_string": {
      "query": "*Failed*",
      "fields": [
        "my-message"
      ],
      "analyze_wildcard": true
    }
  }
}
```

or wildcard
```json
{
  "query": {
    "wildcard": {
      "my-field": {
        "value": "*Failed*"
      }
    }
  }
}
```

## Starts with

Field `my-message` starts with `MyCompany.API`
```
{
  "query": {
    "match_phrase_prefix": {
      "my-message": "MyCompany.API"
    }
  }
}
```

Filters for logzio kibana:

## Contains with wildcard

Field `Msg.Message` contains `Filtering`
```
{
  "query": {
    "wildcard": {
      "Msg.Message": {
        "boost": 1,
        "rewrite": "constant_score",
        "value": "*Filtering*"
      }
    }
  }
}
```

Field `Msg.Data.obj.FilteredEntities` contains `EstimatedDeliveryDateThresholdServiceTypeFilter`
```
{
  "query": {
    "wildcard": {
      "Msg.Data.obj.FilteredEntities": {
        "boost": 1,
        "rewrite": "constant_score",
        "value": "*EstimatedDeliveryDateThresholdServiceTypeFilter*"
      }
    }
  }
}
```
