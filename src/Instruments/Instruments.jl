module Instruments
using Statistics: var

# export from widgets
export Widget, Stock, Commodity, Bond
# exports from financial_instruments
export FinancialInstrument,
    Option,
    CallOption,
    PutOption,
    EuroCallOption,
    AmericanCallOption,
    EuroPutOption,
    AmericanPutOption,
    Future

export get_volatility, add_price_value, get_prices # exporting this to make tests easier

include("widgets.jl")
include("financial_instruments.jl")

end #module
