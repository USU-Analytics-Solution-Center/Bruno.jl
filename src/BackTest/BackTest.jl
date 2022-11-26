module BackTest

using ..Instruments
using ..DataGeneration
using ..Models

# --- functions that find the returns for a given hedging Strat
abstract type Hedging end

primitive type Naked <: Hedging 8 end
primitive type RebalanceDeltaHedge <: Hedging 8 end
primitive type StaticDeltaHedge <: Hedging 8 end
include("hedging.jl")

include("strategy.jl")

export Hedging, Naked, RebalanceDeltaHedge, StaticDeltaHedge
export buy, sell
export find_correlation_coeff, strategy_returns, strategy

end # module 
