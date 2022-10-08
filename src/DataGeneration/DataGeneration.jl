module DataGeneration
using Statistics: mean, var
using LinearAlgebra: dot

using ..Instruments
export makedata, getTime, data_gen_input
export DataGenInput, LogDiffInput, BootstrapInput, TSBootMethod, Stationary, MovingBlock, CircularBlock
export opt_block_length

export factory

"""abstract supertype for all data generation inputs to use with `makedata()` function. 
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
- `nSimulation::Integer`: the number of simulations to run.  
## Outputs
- `data::AbstractArray`: nTimeStep x nSimulation Real valued array, where each column
                         contains the data for one simulation, and each row contains
                         data for each timestep

## Example
```jldoctest
julia> # initialize parameters
julia> nTimeStep = 100;
julia> input1 = LogDiffInput(nTimeStep);

julia> # create a dataset using the log diffusion model
julia> data1 = makedata(input1, 1)

julia> # create another dataset with 2 simulation runs using a startionary bootstrap 
julia> input2 = BootstrapInput(data1, Stationary; n=100);
julia> data2 = makedata(input2, 2)
```
"""
makedata(input::Any) = error("Use a DataGenInput subtype to synthesize data")

include("logdiffusion.jl")
include("bootstrap.jl")
include("factory.jl")

end # module 
