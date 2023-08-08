# Proposing a new Latency SLO

To propose a Latency Service Level Objective (SLO), we can rely on past performance information based on 14 days of data for a specific service transaction. The past performance is measured using the 95th percentile of duration in seconds, excluding server errors.

While using this approach, we have observed that a service transaction that adheres to the Latency SLO may experience constant and volatile latency times during a week. This variability occurs due to infrastructure unavailability, service issues, or service dependencies (other microservices).

To accurately set an SLO that accommodates such variations, we can adopt these steps:

## Step \#1: Checking the average latency consistency for a set of periods with Standard Deviation

The idea of this approach is to determine whether the SLI measurements of a system exhibit **excessive volatility** by assessing their proximity to the mean (average) over a specific period.

We typically assume that a variation of **between 5% to 10%** in measurements is considered a low volatile system.

If the variation **exceeds 20%**, this might suggest a performance issue within the system, due to infrastructure, application, or service dependency issues. We can either review the SLO to set a new target, ask the team to optimize the system or discard it entirely.

To discover if the SLI measurements are volatile, pick the 95th percentile (p95) of duration for each period in three to five periods. Suppose you have the following p95 durations in seconds:
```
18.52s, 51.25s, 47.50s, 24.50s, and 24.50s.
```

Calculate the average (mean) of these measurements to obtain 33.25 seconds.

To assess if this 33.25s is a trustworthy candidate for the new latency SLO, calculate the variance for each measurement. The variance is the sum of the squared differences between each duration and the mean (33.25 seconds), divided by the total number of observed periods:
```
Variance = (((1st p95 result - mean result)\^2) + ((2nd p95 result - mean result)\^2) + ...) ÷ Count(set) =\> 179.44 seconds squared.
```

To check the consistency or trustworthiness of the mean (33.25), calculate the square root of the variance, which is known as the standard deviation. The standard deviation measures the variability of the measurements. If the standard deviation is high, it could indicate that the durations are not consistent over time:
```
Standard deviation** = √Variance =\> 13.40 seconds.
```
Calculate the Coefficient of Variation by dividing the standard deviation by the mean. This will produce a ratio expressed as a percentage:
```
Coefficient of variation %** = (standard deviation ÷ mean) \* 100 =\> 13.40 ÷ 33.25 =\> 40.28%.
```

This indicates that the mean is not consistent with the measurements and would not be a suitable proposal for an SLO. The variation is over 40%.

## Step \#2: Propose an SLO

We have two approaches to propose an SLO.

### Approach \#1: Add percentage buffer to the the mean

Once the average of the measurements is calculated and if they exhibit **low volatility**, an additional buffer of around 20% could be introduced to accommodate unexpected variations.

```
Proposed Latency SLO = mean \* (1 + 20%) =\> 33.25 \* 1.2 =\> 39.90 seconds
```

### Approach \#2: Add coefficient of variation to the mean

One reasonable way to propose the new SLO is by adding the **coefficient of variation to the mean**. Additionally, we must add a buffer to account for variability or potential issues that may occur in the platform, rather than relying solely on the raw coefficient.

Thus, the new proposed latency SLO would be calculated as follows:

```
Proposed Latency SLO** = mean + (mean \* (1 + Coefficient of variation%)) \* (1 + 20%) =\> 33.25 \* (1 + 40.28%) \* (1 + 20%) =\> 33.25 \* 1.4028 \* 1.2 =\> 55.97 seconds
```

### Approach \#3: Add the product of zScore and standard deviation to the mean**

The second approach is to propose an SLO for the chosen percentile using the **z-score scaling factor** (or standard score), which is a statistical measurement that shows how many standard deviations a particular value is from the mean. Positive z-scores indicate that the measurement is above the average, while negative z-scores indicate that the measurement is below the average. The z-score scaling factor for the desired percentile can be obtained from a Z Score percentile distribution table like this <https://www.mymathtables.com/statistic/z-score-percentile-normal-distribution.html>[Z Score Percentile Distribution Table (mymathtables.com)](https://www.mymathtables.com/statistic/z-score-percentile-normal-distribution.html).

The most common percentiles used by industry using quantile function Φ\^(-1)(percentile/100) are:

| **Percentile** | **z-Score**  |
|----------------|--------------|
| 99.99          | 3.719        |
| 99.95          | 3.291        |
| 99.90          | 3.090        |
| 99.50          | 2.576        |
| 99.00          | 2.326        |
| 97.00          | 1.880        |
| 95.00          | 1.645        |
| 90.00          | 1.282        |
| 50.00\*        | 0            |

*\* in normal distribution, 50.00 stands for the median: 50% of data points fall below and above the mean (average).*

Some other available zScore for percentiles

If we pick 95th percentile from the table, we will get zScore of 1.645. We will use it in the following formula to get a proposed SLO.
```
Proposed Latency SLO = average + (zScore scaling factor \* standard deviation) =\> 33.25 secs + (1.645 \* 13.40 secs) =\> 55.29 seconds.
```
This calculation ensures that the SLO takes into account the variability of the data (standard deviation) and sets the threshold for the SLO accordingly, providing a more realistic and effective SLO for the given dataset.
