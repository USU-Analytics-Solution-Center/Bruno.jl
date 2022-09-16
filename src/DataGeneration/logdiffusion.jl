import Dates.DateTime
import Dates.Second
import Random.rand
import Distributions.Normal


"""
## Description
ParamLogDiff contains parameters that are used to synthesize data
from a log-normal diffusion process of the form

``P_{t+1} = P_t \\cdot e^{drift + volatility \\cdot v}``

where P_t is the value of the data at timestep t. The drift and 
volatility represent the mean and standard deviation of a normal 
distribution. The equation given above expresses them as such by 
letting v be a draw from a standard normal distribution which is 
then shifted and scaled by the drift and volatility terms

## Syntax
```
P = ParamLogDiff(nTimeStep) 
P = ParamLogDiff(..., "name", value)
```

## Positional Inputs
- `nTimeStep::Integer`: nTimeStep is the number of time steps 
                        to synthesize.

## Name-Value Inputs
- `initial::Real`: initial is the assumed value at the 0th time step.
                   Default: 100.
- `volatility::Real`: volatility expresses the price volatility as 
                      a standard deviation per time step. Default: 9.3e-3
- `drift::Real`: The drift parameter describes the mean of the 
                 log-normal diffusion process. Default 5.38e-4

## Example

```
using Bruno

# initialize first parameter with default values
nTimeStep = 100
Param1 = ParamLogDiff(nTimeStep)

# initialize a second parameter with zero volatility
Param2 = ParamLogDiff(nTimeStep, volatility=0)

```

"""
struct ParamLogDiff <: DataGenInput
    nTimeStep::Integer # number of timesteps to simulate
    initial::Real # in dollars
    volatility::Real # volatility as a standard deviation
    drift::Real # 
    ParamLogDiff(nTimeStep; initial=100, volatility=0.00930, drift=0.000538) = 
        new(nTimeStep, initial, volatility, drift)
end

"""
## Description
getData is a function that generates data according to the parameter type

## Syntax
```
data = getData(Param)
data = getData(Param, nSimulation)
```

## Positional Inputs
- `Param::DataGenerator`: Parameters that describe the desired data generating process  
- `nSimulation::Integer`: nSimulation is the number of simulations to run.  
Possible DataGenInput parameter types are
- `::ParamLogDiff` - log-normal diffusion process 
- `::BootstrapInput{MovingBlock}`
- `::BootstrapInput{CircularBlock}`
- `::BootstrapInput{Stationary}`

DataGenInput parameter types can be constructed directly or with `data_gen_input()` function.

## Outputs
- `data::AbstractArray`: nTimeStep x nSimulation Real valued array, where each column
                         contains the data for one simulation, and each row contains
                         data for each timestep

## Example
```
# initialize parameters
nTimeStep = 100
Param1 = ParamLogDiff(nTimeStep)
Param2 = ParamLogDiff(nTimeStep, volatility=0)

# create two datasets, one with default values, the second with no volatility
data1 = getData(Param1)
data2 = getData(Param2)

# create a third dataset with 100 simulation runs 
nSimulation = 100
data3 = getData(Param1,nSimulation)

# plot results
plt = plot(data3, show=true, color="blue", legend=false)
plot!(plt, data1, show=true, color="red", legend=false, linewidth=3)
```
"""
function getData(Param::ParamLogDiff, nSimulation::Integer=1)
    
    # compute array of random values
    nData = Param.nTimeStep + 1
    data = zeros((nData, nSimulation))
    data[2:nData,:] = rand(Normal(Param.drift,Param.volatility),
         (Param.nTimeStep,nSimulation))
    data = exp.(cumsum(data,dims=1) .+ log(Param.initial))

    # export values
    return data

end

"""
## Description
`getTime` is a function that generates a corresponding date-time array for data generated
    with a `ParamLogDiff` input in `getData`

## Syntax
```julia
data = getTime(Param)
data = getTime(Param, initial)
```

## Positional Inputs
- `Param::ParamLogDiff`: Parameters that describe the desired log-diffusion process  
- `initial::DateTime`: The time that corresponds to the `initial` parameter in `getData`

## Outputs
- `time::Array{DateTime,2}`: nStepSize x 1 DateTime array, where each value is the time
                             for each row of data returned by `getData`.

## Example
```
import Plots.plot
import Plots.plot!
using Bruno.DataGeneration.LogDiffusion

# initialize parameters
nTimeStep = 100
Param1 = ParamLogDiff(nTimeStep)
Param2 = ParamLogDiff(nTimeStep, volatility=0)

# create two datasets, one with default values, the second with no volatility
data1 = getData(Param1)
data2 = getData(Param2)

# create a third dataset with 100 simulation runs 
nSimulation = 100
data3 = getData(Param1, nSimulation)

# get time axis for each dataset
time1 = getTime(Param1)
time2 = getTime(Param2)
time3 = getTime(Param1)

# plot results
plt = plot(time3, data3, show=true, color="blue", legend=false)
plot!(plt, time1, data1, show=true, color="red", legend=false, linewidth=3)
```

"""
function getTime(Param::ParamLogDiff, tStart=DateTime(2000))
    secondPerDay = (3600*24)
    nSecondPerStepInt = floor(Param.dt*secondPerDay)
    nSecondPerStepSec = Second(nSecondPerStepInt)
    nSecondAll = Second(nSecondPerStepInt*Param.nTimeStep)

    tFinal = tStart + nSecondAll
    time = tStart:nSecondPerStepSec:tFinal
    return time
end