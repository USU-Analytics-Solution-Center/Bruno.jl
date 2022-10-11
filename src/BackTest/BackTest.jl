module BackTest

using ..Instruments
# --- Back Tests for Stocks, Commodities and the like
abstract type Indicator end

primitive type MeanReversion <: Indicator 8 end
primitive type BollingerBands <: Indicator 8 end
primitive type PairsTrading <: Indicator 8 end

include("indicator.jl")
end # module 