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

end # module 
