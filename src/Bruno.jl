module Bruno
include("DataGeneration/DataGeneration.jl")
using .DataGeneration

export ParamLogDiff 
export getData, getTime, data_gen_input
export DataGenInput, BootstrapInput, TSBootMethod, Stationary, MovingBlock, CircularBlock
end # module
