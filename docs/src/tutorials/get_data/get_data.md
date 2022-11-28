# Data Generation

## Overview
Data generation or simulation is a way to get more timeseries data from either a small data set or a parametric simulating model. Data generation in Bruno uses a [DataGenInput](@ref data_gen_inputs) subtype as an input into the [makedata](@ref makedata) function.

## Creating a simulated timeseries 
This example shows how to make a julia `matrix` with two simulated time series using the log diffusion parameteric model (discrete geometric Brownian motion). To use other data generation models check the reference for all current [data generation inputs](@ref data_gen_inputs)
```
# creating a LogDiffInput struct with input parameters
input = LogDiffInput(; 
    nTimeSteps=252, 
    initial=50, 
    volatility=.3,
    drift=.08
)

# creating 2 new timeseries
timeseries = makedata(input, 2) 
```