module DataGeneration
using Statistics: mean, var
using LinearAlgebra: dot

using ..Instruments
export getData, getTime, data_gen_input
export DataGenInput, LogDiffInput, BootstrapInput, TSBootMethod, Stationary, MovingBlock, CircularBlock
export opt_block_length

export factory

abstract type DataGenInput end
include("logdiffusion.jl")
include("bootstrap.jl")
include("factory.jl")


"""
    data_gen_input(data_gen_type::Symbol; kwargs...)

Create DataGenInput subtype to be used by `getData()` function.

Possible data_gen_type symbol inputs are
- `:MBBootstrap`
- `:CBBootstrap`
- `:StationaryBootstrap`
- `:IIDBootstrap`
- `:LogDiffusion`

# Keyword arguments 
Keyword arguments required differ on the DataGenInput subtype that is requested.
For all bootstraps (:MBBootstrap, :CBBootstrap, StationaryBootstrap, and :IIDBootstrap)
Required keyword araguments:
- `input_data::Array{<:Real}`: data to be resampled. Must be a 1-D array
- `n::Integer`: size of resampled output data.
- `block_size::Integer`: block size to use. Defaults to opt_block_length(input_data).

For :LogDiffusion, required keyword arguments:
- `nTimeStep::Integer`: number of timesteps to simulate
- `initial::Real`: initial price in dollars
- `volatility::Real`: volatility as a standard deviation
- `drift::Real`: expected annual rate of return

# Examples
```
using Bruno 

kwargs = (input_data = [1,2,3,4,5], n = 20, block_size = 3)
input = data_gen_input(:MBBootstrap ; kwargs...)
```
"""
function data_gen_input(data_gen_type::Symbol; kwargs...)
    if data_gen_type == :MBBootstrap
        block_size = :block_size in keys(kwargs) ? kwargs[:block_size] : opt_block_length(kwargs[:input_data], CircularBlock())
        BootstrapInput{MovingBlock}(kwargs[:input_data],
                                kwargs[:n],
                                block_size
       ) 
    elseif data_gen_type == :CBBootstrap
        block_size = :block_size in keys(kwargs) ? kwargs[:block_size] : opt_block_length(kwargs[:input_data], CircularBlock())
        BootstrapInput{CircularBlock}(kwargs[:input_data],
                                kwargs[:n],
                                block_size
       ) 
    elseif data_gen_type == :StationaryBootstrap
        block_size = :block_size in keys(kwargs) ? kwargs[:block_size] :  opt_block_length(kwargs[:input_data], Stationary())
        BootstrapInput{Stationary}(kwargs[:input_data],
                                kwargs[:n],
                                block_size
       ) 
    elseif data_gen_type == :IIDBootstrap 
        BootstrapInput{CircularBlock}(;input_data=kwargs[:input_data],
                                    n=kwargs[:n],
                                    block_size=1
        )
    elseif data_gen_type == :LogDiffusion
        ParamLogDiff(kwargs[:nTimeStep]; 
                    initial = kwargs[:initial], 
                    volatility = kwargs[:volatility],
                    drift = kwargs[:drift]             
        )
    else
        error("Please use one of the data gen patterns provided")
    end
end
end # module 
