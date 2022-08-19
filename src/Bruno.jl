module Bruno
include("DataGeneration/DataGeneration.jl")
using .DataGeneration

export ParamLogDiff, TSBootMethod, StationaryBootstrap, MovingBlockBootstrap, 
    CircularBlockBootstrap
export getData, getTime
end # module
