module Models
    
using ..Instruments
using ..DataGeneration

# ---- Types of Monte Carlo pricing -----
abstract type MonteCarloModel end

primitive type LogDiffusion <: MonteCarloModel 8 end
primitive type StationaryBootstrap <: MonteCarloModel 8 end
primitive type CircularBlockBootstrap <: MonteCarloModel 8 end


# ----- Model types ------
abstract type Model end

primitive type BlackScholes <: Model 8 end
primitive type BinomialTree <: Model 8 end
primitive type MonteCarlo{T <: MonteCarloModel} <: Model 8 end


include("pricingmodels.jl")

export price!, b_tree
export BinomialTree, BlackScholes
export MonteCarlo, MonteCarloModel, LogDiffusion, StationaryBootstrap, 
CircularBlockBootstrap

end #module