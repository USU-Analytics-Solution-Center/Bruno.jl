module DataGeneration

export ParamLogDiff, TSBootMethod, StationaryBootstrap, MovingBlockBootstrap, 
    CircularBlockBootstrap
export getData, getTime
include("logdiffusion.jl")
greet2() = print("Hello World!")
include("bootstrap.jl")

end # module 