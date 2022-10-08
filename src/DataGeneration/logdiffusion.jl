import Dates.DateTime
import Dates.Second
import Random.rand
import Distributions.Normal


"""
    LogDiffInput(nTimeStep, initial, volatility, drift)
    LogDiffInput(nTimeStep; kwargs...)
    LogDiffInput(;kwargs...)

contains parameters that are used by `makedata()` to synthesize data
from a log-normal diffusion process of the form

``P_{t+1} = P_t \\cdot e^{drift + volatility \\cdot v}``

where P_t is the value of the data at timestep t. The drift and 
volatility represent the mean and standard deviation of a normal 
distribution. The equation given above expresses them as such by 
letting v be a draw from a standard normal distribution which is 
then shifted and scaled by the drift and volatility terms

## Arguments

- `nTimeStep::Integer`: nTimeStep is the number of time steps to synthesize.
- `initial::Real`: initial is the assumed value at the 0th time step. Default: 100.
- `volatility::Real`: volatility expresses the price volatility as a standard deviation per time step. Default: 9.3e-3
- `drift::Real`: The drift parameter describes the mean of the log-normal diffusion process. Default 5.38e-4

## Example
```jldoctest
julia> using Bruno

julia> input1 = LogDiffInput(250, 100, .05, .1)

julia> # initialize first input with default values
julia> input2 = LogDiffInput(250)

julia> # initialize a second input with zero volatility
julia> kwargs = Dict(:nTimeStep=>250, :initial=>100, :volatility=>.05, :drift=.1)
julia> input3 = LogDiffInput(;kwargs...)
```
"""
struct LogDiffInput <: DataGenInput
    nTimeStep::Integer # number of timesteps to simulate
    initial::Real # in dollars
    volatility::Real # volatility as a standard deviation
    drift::Real # 
    # constructor for kwargs
    function LogDiffInput(;nTimeStep, initial=100, volatility=0.00930, drift=0.000538) 
        nTimeStep > 0 ? nothing : error("nTimeStep must be a positive integer")
        volatility >= 0 ? nothing : error("volatility cannot be negative")
        new(nTimeStep, initial, volatility, drift)
    end
    # constructor for ordered inputs
    function LogDiffInput(nTimeStep, initial, volatility, drift)  
        nTimeStep > 0 ? nothing : error("nTimeStep must be a positive integer")
        volatility >= 0 ? nothing : error("volatility cannot be negative")
        new(nTimeStep, initial, volatility, drift)
    end
end
# outer constructor for passing just nTimeStep
LogDiffInput(nTimeStep::Int; initial=100, volatility=.00930, drift=.000538) = 
    LogDiffInput(nTimeStep, initial, volatility, drift)


function makedata(Input::LogDiffInput, nSimulation::Integer=1)
    
    # compute array of random values
    nData = Input.nTimeStep + 1
    data = zeros((nData, nSimulation))
    data[2:nData,:] = rand(Normal(Input.drift,Input.volatility),
         (Input.nTimeStep,nSimulation))
    data = exp.(cumsum(data,dims=1) .+ log(Input.initial))

    # export values
    return data

end

"""
## Description
`getTime` is a function that generates a corresponding date-time array for data generated
    with a `LogDiffInput` input in `makedata`

## Syntax
```julia
data = getTime(Input)
data = getTime(Input, initial)
```

## Positional Inputs
- `Input::LogDiffInput`: Parameters that describe the desired log-diffusion process  
- `initial::DateTime`: The time that corresponds to the `initial` parameter in `makedata`

## Outputs
- `time::Array{DateTime,2}`: nStepSize x 1 DateTime array, where each value is the time
                             for each row of data returned by `makedata`.

## Example
```
import Plots.plot
import Plots.plot!
using Bruno.DataGeneration.LogDiffusion

# initialize parameters
nTimeStep = 100
input1 = LogDiffInput(nTimeStep)
input2 = LogDiffInput(nTimeStep, volatility=0)

# create two datasets, one with default values, the second with no volatility
data1 = makedata(input1)
data2 = makedata(input2)

# create a third dataset with 100 simulation runs 
nSimulation = 100
data3 = makedata(input1, nSimulation)

# get time axis for each dataset
time1 = getTime(input1)
time2 = getTime(input2)
time3 = getTime(input1)

# plot results
plt = plot(time3, data3, show=true, color="blue", legend=false)
plot!(plt, time1, data1, show=true, color="red", legend=false, linewidth=3)
```

"""
function getTime(Input::LogDiffInput, tStart=DateTime(2000))
    secondPerDay = (3600*24)
    nSecondPerStepInt = floor(Input.dt*secondPerDay)
    nSecondPerStepSec = Second(nSecondPerStepInt)
    nSecondAll = Second(nSecondPerStepInt*Input.nTimeStep)

    tFinal = tStart + nSecondAll
    time = tStart:nSecondPerStepSec:tFinal
    return time
end
