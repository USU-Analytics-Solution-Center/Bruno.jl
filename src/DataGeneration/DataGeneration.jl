module DataGeneration

export ParamLogDiff, TSBootMethod, StationaryBootstrap, MovingBlockBootstrap, 
    CircularBlockBootstrap
export getData, getTime
include("logdiffusion.jl")
include("bootstrap.jl")

end # module 
