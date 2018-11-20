```
// take three random estimated delivery times (i.e. 2, 5 and 10 days)
var generator = fixture.Create<Generator<int>>();
List<int> predictedDays = generator.Where(x => x >= 2 && x <= 10)
    .Distinct().Take(3)
    .ToList();
predictedDays.Sort();

var estimatedDelivery = new EstimatedDeliveryTimeInDays
{
    Minimum = predictedDays[0],
    BestGuess = predictedDays[1],
    Maximum = predictedDays[2]
};
```
