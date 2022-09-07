module DataGeneration
using Statistics: mean, var
using LinearAlgebra: dot

export getData, getTime, data_gen_input
export DataGenInput, BootstrapInput, TSBootMethod, Stationary, MovingBlock, CircularBlock
export opt_block_length

abstract type DataGenInput end
include("logdiffusion.jl")
include("bootstrap.jl")


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
- `dt::Real` assumed change in time between samples in days.

For :LogDiffusion, required keyword arguments:
- `nTimeStep::Integer`: number of timesteps to simulate
- `initial::Real`: initial price in dollars
- `dt::Real`: change in time between timesteps in days
- `volatility::Real`: volatility as a standard deviation
- `drift::Real`: expected annual rate of return

# Examples
```
using Bruno 

kwargs = (input_data = [1,2,3,4,5], n = 20, block_size = 3, dt = 1)
input = data_gen_input(:MBBootstrap ; kwargs...)
```
"""
function data_gen_input(data_gen_type::Symbol; kwargs...)
    if data_gen_type == :MBBootstrap
        if :block_size in keys(kwargs)
            block_size = kwargs[:block_size]
        else
            block_size = opt_block_length(kwargs[:input_data], CircularBlock())
        end
        BootstrapInput{MovingBlock}(kwargs[:input_data],
                                kwargs[:n],
                                block_size,
                                kwargs[:dt]
       ) 
    elseif data_gen_type == :CBBootstrap
        if :block_size in keys(kwargs)
                block_size = kwargs[:block_size]
        else
                block_size = opt_block_length(kwargs[:input_data], CircularBlock())
        end
        BootstrapInput{CircularBlock}(kwargs[:input_data],
                                kwargs[:n],
                                block_size,
                                kwargs[:dt]
       ) 
    elseif data_gen_type == :StationaryBootstrap
        if :block_size in keys(kwargs)
            block_size = kwargs[:block_size]
        else
            block_size = opt_block_length(kwargs[:input_data], Stationary())
        end
        BootstrapInput{Stationary}(kwargs[:input_data],
                                kwargs[:n],
                                block_size,
                                kwargs[:dt]
       ) 
    elseif data_gen_type == :IIDBootstrap 
        BootstrapInput{CircularBlock}(;input_data=kwargs[:input_data],
                                    n=kwargs[:n],
                                    block_size=1,
                                    dt=kwargs[:dt]
        )
    elseif data_gen_type == :LogDiffusion
        ParamLogDiff(kwargs[:nTimeStep]; 
                    initial = kwargs[:initial], 
                    dt = kwargs[:dt], 
                    volatility = kwargs[:volatility],
                    drift = kwargs[:drift]             
        )
    else
        println("Please use one of the data gen patterns provided")
    end
end
end # module 
