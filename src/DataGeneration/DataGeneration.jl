module DataGeneration
using Statistics: mean, var
using LinearAlgebra: dot

using ..Instruments
export makedata, getTime, data_gen_input
export DataGenInput,
    LogDiffInput, BootstrapInput, TSBootMethod, Stationary, MovingBlock, CircularBlock
export opt_block_length

export factory

"""Abstract supertype for all data generation inputs to use with `makedata()` function. 
Use `subtypes(DataGenInput)` for a list of all possible data generation inputs. """
abstract type DataGenInput end

"""
    makedata(Input::LogDiffInput, nSimulation::Integer)

generates data according to the DataGenInput struct provided

Possible DataGenInput types are
- `::LogDiffInput`
- `::BootstrapInput{MovingBlock}`
- `::BootstrapInput{CircularBlock}`
- `::BootstrapInput{Stationary}`

## Arguments
- `Input<:DataGenInput`:  struct with parameters to generate data
- `nSimulation`: the number of simulations to run.  
## Outputs
- `data`:   nTimeStep x nSimulation array, where each column
                         contains the data for one simulation, and each row contains
                         data for each timestep

## Example
```julia
nTimeStep = 100;
input1 = LogDiffInput(nTimeStep);

# create a dataset using the log diffusion model
data1 = makedata(input1, 1)

# create another dataset with 2 simulation runs using a startionary bootstrap 
input2 = BootstrapInput(data1, Stationary; n=100);
data2 = makedata(input2, 2)
```
"""
makedata(input) = error("Use a DataGenInput subtype to synthesize data")

include("logdiffusion.jl")
include("bootstrap.jl")
include("factory.jl")

end # module 
