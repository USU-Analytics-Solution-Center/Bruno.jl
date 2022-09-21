module Models
    
using ..Instruments
using ..DataGeneration

abstract type Model end

primitive type BlackScholes <: Model 8 end
primitive type BinomialTree <: Model 8 end
primitive type MonteCarlo <: Model 8 end

end #module