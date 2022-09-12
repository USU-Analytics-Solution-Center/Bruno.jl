module Instruments

# export from widgets
export Widget, Stock, Commodity, Bond
# exports from models
export Model, BlackScholes, BinomialTree, MonteCarlo
# exports from financial_instruments
export FinancialInstrument, Option, CallOption, PutOption, Future
    
include("widgets.jl")
include("models.jl")
include("financial_instruments.jl")

end #module