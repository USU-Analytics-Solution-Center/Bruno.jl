module Models
    
using ..Instruments
using ..DataGeneration

# ---- Types of Monte Carlo pricing -----
abstract type MonteCarloModel end

primitive type LogDiffusion <: MonteCarloModel 8 end
primitive type MCBootstrap <: MonteCarloModel 8 end


# ----- Model types ------
abstract type Model end

primitive type BlackScholes <: Model 8 end
primitive type BinomialTree <: Model 8 end
abstract type MonteCarlo{T <: MonteCarloModel} <: Model end


include("pricingmodels.jl")

export price!, b_tree
export BinomialTree, BlackScholes
export MonteCarlo, MonteCarloModel, LogDiffusion, MCBootstrap

end #module