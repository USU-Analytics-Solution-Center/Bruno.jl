module Bruno
# exports from Instruments 
include("Instruments/Instruments.jl")

using .Instruments
export Widget, Stock, Commodity, Bond 
export FinancialInstrument, Option, CallOption, PutOption, EuroCallOption,
AmericanCallOption, EuroPutOption, AmericanPutOption, Future

export get_volatility, add_price_value # exporting this to make tests easiers

# DataGeneration submodule
include("DataGeneration/DataGeneration.jl")
using .DataGeneration

export LogDiffInput 
export makedata, getTime, data_gen_input
export DataGenInput, BootstrapInput, TSBootMethod, Stationary, MovingBlock, CircularBlock
export opt_block_length
export factory

# Models submodule
include("Models/Models.jl")

export BinomialTree, BlackScholes
export price!, b_tree
using .Models
export MonteCarlo, MonteCarloModel, LogDiffusion, MCBootstrap

# BackTest Module
include("BackTest/BackTest.jl")
using .BackTest
export Naked, RebalanceDeltaHedge, StaticDeltaHedge
export find_correlation_coeff, strategy_returns

end # module
