import Random.rand
import Distributions.Normal


"""
    LogDiffInput(nTimeStep, initial, volatility, drift)
    LogDiffInput(nTimeStep; kwargs...)
    LogDiffInput(;kwargs...)

contains parameters that are used by `makedata()` to synthesize data
from a log-normal diffusion process of the form

```math 
P_{t+1} = P_t \\cdot e^{drift + volatility \\cdot v}
```

where P_t is the value of the data at timestep t. The drift and 
volatility represent the mean and standard deviation of a normal 
distribution. The equation given above expresses them as such by 
letting v be a draw from a standard normal distribution which is 
then shifted and scaled by the drift and volatility terms

## Arguments

- `nTimeStep::Integer`:  the number of time steps to synthesize.
- `initial::Real`:  the assumed value at the 0th time step. Default: 100.
- `volatility::Real`:  the price volatility as a standard deviation in terms of implied time period. Default: 0.3
- `drift::Real`: The drift parameter describes the mean of the log-normal diffusion process 
given in terms of the entire implied time period (if simulating a year, drift would be annual 
expected return). Default 0.02

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
struct LogDiffInput <: DataGenInput
    nTimeStep::Integer # number of timesteps to simulate
    initial::Real # in dollars
    volatility::Real # volatility as a standard deviation
    drift::Real # 
    # constructor for kwargs
    function LogDiffInput(;
        nTimeStep,
        initial = 100,
        volatility = 0.3,
        drift = 0.02,
    )
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
LogDiffInput(nTimeStep::Int; initial = 100, volatility = 0.3, drift = 0.02) =
    LogDiffInput(nTimeStep, initial, volatility, drift)


function makedata(Input::LogDiffInput, nSimulation::Integer = 1)

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
