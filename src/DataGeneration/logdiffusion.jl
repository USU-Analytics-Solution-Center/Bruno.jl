import Random.rand
import Distributions.Normal


"""
    LogDiffInput(nTimeStep, initial, volatility, drift)
    LogDiffInput(;kwargs...)

Contains parameters that are used by `makedata()` to synthesize data
from a log-normal diffusion process of the form.

```math 
P_{t+1} = P_t \\cdot e^{drift + volatility \\cdot v}
```

Where P_t is the value of the data at timestep t. The drift and 
volatility represent the mean and standard deviation of a normal 
distribution. The equation given above expresses them as such by 
letting v be a draw from a standard normal distribution which is 
then shifted and scaled by the drift and volatility terms.

## Arguments

- `nTimeStep::Int64`:  The number of time steps to synthesize.
- `initial::Float64`:  The assumed value at the 0th time step. Default: 100.
- `volatility::Float64`:  The price volatility as a standard deviation in terms of implied time period. Defaults to 0.3.
- `drift::Float64`: The drift parameter describes the mean of the log-normal diffusion process 
given in terms of the entire implied time period (if simulating a year, drift would be annual 
expected return). Defaults to 0.02.

## Example
```julia
input1 = LogDiffInput(250, 100, .05, .1)

# initialize first input with default values
input2 = LogDiffInput(250)

# initialize a second input with zero volatility
kwargs = Dict(:nTimeStep=>250, :initial=>100, :volatility=>.05, :drift=>.1)
input3 = LogDiffInput(;kwargs...)
```
"""
struct LogDiffInput{TI,TR} <: DataGenInput
    nTimeStep::TI # number of timesteps to simulate
    initial::TR # in dollars
    volatility::TR # volatility as a standard deviation
    drift::TR # 
    # constructor for kwargs
    function LogDiffInput{TI,TR}(;
        nTimeStep,
        initial = 100,
        volatility = 0.3,
        drift = 0.02,
    ) where {TI,TR}
        nTimeStep > 0 ? nothing : error("nTimeStep must be a positive integer")
        volatility >= 0 ? nothing : error("volatility cannot be negative")
        new(nTimeStep, initial, volatility, drift)
    end
    # constructor for ordered inputs
    function LogDiffInput{TI,TR}(nTimeStep, initial, volatility, drift) where {TI,TR}
        nTimeStep > 0 ? nothing : error("nTimeStep must be a positive integer")
        volatility >= 0 ? nothing : error("volatility cannot be negative")
        new(nTimeStep, initial, volatility, drift)
    end
end
# outer constructor for passing just nTimeStep
function LogDiffInput(nTimeStep, initial = 100, volatility = 0.3, drift = 0.02)
    TI = typeof(nTimeStep)
    initial, volatility, drift = promote(initial, volatility, drift)
    TR = typeof(initial)
    return LogDiffInput{TI,TR}(nTimeStep, initial, volatility, drift)
end
function LogDiffInput(;nTimeStep, initial = 100, volatility = 0.3, drift = 0.02)
    TI = typeof(nTimeStep)
    initial, volatility, drift = promote(initial, volatility, drift)
    TR = typeof(initial)
    return LogDiffInput{TI,TR}(nTimeStep, initial, volatility, drift)
end



function makedata(Input::LogDiffInput, nSimulation = 1)

    # compute array of random values
    nData = Input.nTimeStep + 1
    data = zeros((nData, nSimulation))

    nudt = (Input.drift - Input.volatility ^ 2 / 2) / Input.nTimeStep
    sigma = Input.volatility / sqrt(Input.nTimeStep)
    data[2:nData, :] = rand(
        Normal(),
        (Input.nTimeStep, nSimulation),
    ) .* sigma .+ nudt

    # bring back into price
    data = exp.(cumsum(data, dims = 1) .+ log(Input.initial))

    # export values
    return data

end
