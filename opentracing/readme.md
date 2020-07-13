
# OpenTracing

```
docker run -d --name jaeger -e COLLECTOR_ZIPKIN_HTTP_PORT=9411 -p 5775:5775/udp -p 6831:6831/udp -p 6832:6832/udp -p 5778:5778 -p 16686:16686 -p 14268:14268 -p 14250:14250 -p 9411:9411 jaegertracing/all-in-one:1.18
```

## Code
https://github.com/jaegertracing/jaeger-client-csharp

## Jaeger UI 
http://localhost:16686/search

## Create Scope to register spans
```csharp
    using System.Collections.Generic;
    using Newtonsoft.Json;
    using OpenTracing;
    using OpenTracing.Tag;
    using OpenTracing.Util;

    public static class TracingScopeBuilder
    {
        /// <summary>
        /// Creates a tracing scope
        /// </summary>
        /// <param name="serializedContextDictionary">Serialized string that represents key for span context within an operation</param>
        /// <param name="buildSpanName">human readable span name, lowercase</param>
        /// <param name="operationName">A tag to span to name the operation / method being run</param>
        /// <param name="spanKind">Type of span those defined inOpenTracing.Tag.Tags. If none, defaults to <code>Tags.SpanKindServer</code></param>
        /// <param name="spanTags">Additional tags to label the tracing operation</param>
        /// <returns>Disposable IScope</returns>
        public static IScope CreateScope(
            string serializedContextDictionary,
            string buildSpanName,
            string operationName,
            string spanKind = Tags.SpanKindServer,
            Dictionary<string, string> spanTags = null)
        {
            var tracer = GlobalTracer.Instance;

            if (tracer == null)
            {
                return default;
            }

            var spanBuilder = tracer
                .BuildSpan(buildSpanName)
                .WithTag(Tags.SpanKind.Key, spanKind)
                .WithTag("Operation", operationName);

            foreach (var item in spanTags ?? new Dictionary<string, string>())
            {
                spanBuilder.WithTag(item.Key, item.Value);
            }

            if (serializedContextDictionary != null)
            {
                Dictionary<string, string> headers = JsonConvert.DeserializeObject<Dictionary<string, string>>(serializedContextDictionary);

                var spanContext = TracingPropagator.Extract(headers);

                if (spanContext != null)
                {
                    spanBuilder.AsChildOf(spanContext);
                }
            }

            return spanBuilder.StartActive(finishSpanOnDispose: true);
        }

    }
```

Then in your methods to be observed:
```csharp
public async Task ProduceMessageAsync(Guid orderId, IEnumerable<Item> items)
{
    using (var scope = TracingScopeBuilder.CreateScope(this.GetTracingOperationKey(orderId), "produce_message", "register_order", Tags.SpanKindProducer))
    {
        try
        {
            YouKafkaContract.OrderCreated message = OrderMapper.Map(orderId, items);

            var operationLogData = new Dictionary<string, object>
            {
                ["partition.key"] = message.GetPartitionKey() //one or more things you want to log
            };

            scope.Span.Log(DateTimeOffset.Now, operationLogData);

            bool result = await myProducer.ProduceAsync("topic.name", message).ConfigureAwait(false);

            if (result == false)
            {
                scope.Span.SetTag("error", true);
                scope.Span.Log(DateTimeOffset.Now, "delivery.failed");
            }
            else
            {
                scope.Span.Log(DateTimeOffset.Now, "delivery.succeeded");
            }

        }
        catch (Exception ex)
        {
            scope.Span.SetTag("error", true);
            scope.Span.Log(DateTimeOffset.Now, ex.Message);
            throw;
        }
    }
}

    private string GetTracingOperationKey(Guid orderId)
    {
        var operationKey = new Dictionary<string, string>
        {
            ["order.id"] = orderId.ToString()
        };

        return JsonConvert.SerializeObject(operationKey);
    }
```
