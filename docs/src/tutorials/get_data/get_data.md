# Data Generation

## Overview
Data generation or simulation is a way to get more time series data from either a small data set or a parametric simulating model. Data generation in Bruno uses a [DataGenInput](@ref data_gen_inputs) subtype as an input into the [makedata](@ref makedata) function.

## Creating a Simulated Time Series 
This example shows how to make a Julia `matrix` with two simulated time series using the log diffusion parameteric model (discrete geometric Brownian motion). To use other data generation models check the reference for all current [data generation inputs.](@ref data_gen_inputs)
```@meta
DocTestSetup = quote
    using Random
    using Bruno
    Random.seed!(7)
end
```

```jldoctest; output = false
# creating a LogDiffInput struct with input parameters
input = LogDiffInput(; 
    nTimeStep=252, 
    initial=50, 
    volatility=.3,
    drift=.08
)

# creating 2 new timeseries
timeseries = makedata(input, 2) 

# output

253×2 Matrix{Float64}:
 50.0     50.0
 49.5959  50.3851
 51.4994  49.2724
 49.9324  48.9274
 51.0176  49.615
 50.3179  49.6105
 50.2305  48.6962
 49.8319  48.937
 50.7188  48.1659
 50.2982  47.6781
  ⋮       
 46.1999  59.8003
 46.8095  59.6771
 48.6298  58.2181
 47.7224  58.851
 48.2986  57.2786
 48.9256  55.2403
 48.4297  55.3881
 47.832   55.3604
 48.6619  55.5969
```
