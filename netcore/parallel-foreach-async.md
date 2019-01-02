## Current approach

```
var results = new ConcurrentBag<Ranking>();

Parallel.ForEach(merchantIds, merchant =>
{
   Ranking rank = GetRanking(merchantId, deliveryAddress).Result;
   results.Add(rank);
});
```

## Alternative approach

`<PackageReference Include="AsyncEnumerator" Version="2.2.1" />`
 
```
var results = new ConcurrentQueue<Ranking>();
const int MaxDegreeOfParalellism = 10;

await merchantIds.ParallelForEachAsync(async merchantId =>
{
   Ranking rank = await GetRanking(merchantId, deliveryAddress);
   results.Enqueue(rank);
}, MaxDegreeOfParalellism);
```
