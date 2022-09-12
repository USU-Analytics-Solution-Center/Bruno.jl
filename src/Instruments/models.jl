# types for models to dispatch on in order to get values for FinancialInstruments

abstract type Model end

primitive type BlackScholes <: Model 8 end
primitive type BinomialTree <: Model 8 end
primitive type MonteCarlo <: Model 8 end
