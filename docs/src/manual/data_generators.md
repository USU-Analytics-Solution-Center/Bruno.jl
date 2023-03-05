# Data Generation
All data generation methods use the [`makedata`](@ref) function with different structs containing input parameters. 

## Parametric Data Generation
### [Log Diffusion](@id log_diff_manual)
Creating a time series with the [log diffusion model](https://en.wikipedia.org/wiki/Geometric_Brownian_motion) for asset prices (also known as Geometric Brownian Motion) uses the [`LogDiffInput`](@ref) struct.

Note: drift (expected value of returns) and volatility are in terms of the implicit time period for the whole simulated data set. For example, when simulating a year of prices, drift represents the yearly expected return. 

For simulating a year of daily and hourly prices, assuming there are 252 trading days in a year and 6 hours in a trading day.

```@meta 
DocTestSetup = quote
    using Random
    Random.seed!(7)
    using Bruno
end
```

```jldoctest; output = false
# creating a LogDiffInput struct with input parameters
daily_input = LogDiffInput(; 
    nTimeStep=252, 
    initial=50, 
    volatility=.3,
    drift=.08
);

hourly_input = LogDiffInput(; 
    nTimeStep=252*6, 
    initial=50, 
    volatility=.3,
    drift=.08
);

# creating 2 new datasets with 2 timeseries each
daily_timeseries = makedata(daily_input, 2) 
hourly_timeseries = makedata(hourly_input, 2) 


# output

1513×2 Matrix{Float64}:
 50.0     50.0
 49.9128  50.3525
 49.16    50.4056
 48.4867  50.5464
 49.0657  50.9794
 48.8936  51.8134
 48.8482  51.8209
 49.534   51.6294
 48.6209  51.9555
 48.412   51.453
  ⋮       
 54.9409  51.6955
 55.5787  51.5237
 55.3566  51.1798
 56.0371  51.6605
 56.2404  51.9727
 56.9526  52.4751
 56.9197  52.3215
 57.2305  52.6955
 57.5451  52.2957
```

```@meta
DocTestSetup = nothing
```

### Non-Parametric Data Generation

#### [Time-Series Bootstrapping](@id ts_bootstrap_manual)
Time-series bootstrapping samples with replacement from blocks of the original time-series dataset. The three bootstraps included in Bruno are `Stationary`, `MovingBlock`, and `CircularBlock`. 

All time series bootstraps use the [`BootstrapInput`](@ref) struct with parameters. 

* `Stationary` bootstrap (Politis and Romano, 1994) uses exponentially distributed blocksizes.
* `MovingBlock` uses constant sized blocks that do not wrap around the time-series.
* `CircularBlock` uses constant sized blocks that wrap around the time-series.
