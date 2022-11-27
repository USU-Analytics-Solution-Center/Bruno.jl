# Data Generation
All data generation methods use the `makedata` function with different structs containing input parameters. 

## Parametric data generation
### Log Diffusion
Creating a time series with the [log diffusion model](https://en.wikipedia.org/wiki/Geometric_Brownian_motion) for asset prices (also known as Geometric Brownian Motion) uses the `LogDiffInput` struct.

```@docs
LogDiffInput
```

Note that drift (expected value of returns) and volatility are in terms of the implicit time period for the whole simulated data set. For example, when simulating a year of prices, drift represents the yearly expected return. 

For simulating a year of daily and hourly prices, assuming there are 252 trading days in a year and 6 hours in a trading day
```
# creating a LogDiffInput struct with input parameters
daily_input = LogDiffInput(; 
    nTimeSteps=252, 
    initial=50, 
    volatility=.3,
    drift=.08
)

hourly_input = LogDiffInput(; 
    nTimeSteps=252*6, 
    initial=50, 
    volatility=.3,
    drift=.08
)

# creating 2 new datasets with 2 timeseries each
daily_timeseries = makedata(daily_input, 2) 
hourly_timeseries = makedata(hourly_input, 2) 
```

### Non-parametric data generation
#### Time-series bootstrapping
Time-series bootstrapping samples with replacement from blocks of the original time-series dataset. The three bootstraps included in Bruno are `Stationary`, `MovingBlock`, and `CircularBlock`. 

All time series bootstraps use a `BootstrapInput` struct with parameters. 
```@docs
BootstrapInput
```

* `Stationary` bootstrap (Politis and Romano, 1994) uses expnentially distributed blocksizes 
* `MovingBlock` uses constant sized blocks that do not wrap around the time-series
* `CircularBlock` uses constant sized blocks that wrap around the time-series
