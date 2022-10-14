module BackTest

using ..Instruments
using ..DataGeneration
using ..Models
# --- Back Tests for Stocks, Commodities and the like
abstract type Indicator end

primitive type MeanReversion <: Indicator 8 end
primitive type BollingerBands <: Indicator 8 end
primitive type PairsTrading <: Indicator 8 end

include("indicator.jl")

# --- functions that find the returns for a given hedging Strat
abstract type Hedging end

primitive type RatioHedging <: Hedging 8 end

include("hedging.jl")

export RatioHedging
export find_correlation_coeff, get_returns

end # module 