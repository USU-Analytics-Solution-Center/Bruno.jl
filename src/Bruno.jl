module Bruno
# exports from Instruments 
include("Instruments/Instruments.jl")

using .Instruments
export Widget, Stock, Commodity, Bond 
export FinancialInstrument, Option, CallOption, PutOption, EuroCallOption,
AmericanCallOption, EuroPutOption, AmericanPutOption, Future
export AbstractEuroCall, AbstractAmericanCall, AbstractEuroPut, AbstractAmericanPut

# DataGeneration submodule
include("DataGeneration/DataGeneration.jl")
using .DataGeneration

export LogDiffInput 
export getData, getTime, data_gen_input
export DataGenInput, BootstrapInput, TSBootMethod, Stationary, MovingBlock, CircularBlock
export opt_block_length
export factory

# Models submodule
include("Models/Models.jl")

export BinomialTree, BlackScholes
export price!, b_tree
using .Models


end # module
