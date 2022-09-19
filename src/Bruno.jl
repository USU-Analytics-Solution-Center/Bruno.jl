module Bruno
# exports from Instruments 
include("Instruments/Instruments.jl")

using .Instruments
export Widget, Stock, Commodity, Bond 
export FinancialInstrument, Option, CallOption, PutOption, Future

# DataGeneration submodule
include("DataGeneration/DataGeneration.jl")
using .DataGeneration

export ParamLogDiff 
export getData, getTime, data_gen_input
export DataGenInput, BootstrapInput, TSBootMethod, Stationary, MovingBlock, CircularBlock
export opt_block_length
export factory

# Models submodule
include("Models/Models.jl")
using .Models


end # module
