# Hedging/Trading Strategy Testing

## Overview
`strategy_returns()` can back test a trading strategy or test a strategy on simulated future data. 

This tutorial shows how to create a simple trading strategy simulation. It demonstrates: 
* How to create a new type to allow for Julia's [multiple dispatch](https://docs.julialang.org/en/v1/manual/methods/) on the `strategy()` function
* How to create a new method for the `strategy` function
* How to use `strategy_returns` to run the strategy on randomly simulated data

## Create New `Hedging` Type
Each new strategy will need a new type to allow for dispatch. Use this type for `strategy_mode` argument in `strategy_returns`.

```jldoctest strategy; output = false
using Bruno

# creating a new subtype for dispatch
primitive type ExampleStrategy <: Hedging 8 end

# output

```

## [Create a New `strategy` Method](@id strategy_method_tutorial)
`strategy` is the core function in `strategy_returns`. It will need a new method for each different strategy. `strategy` and `strategy_returns` both work for a single `FinancialInstrument` or for a `Vector{<:FinancialInstrument}`, but it needs to be explicit in the function definition. `buy` and `sell` functions are provided to make writing strategies easier.
For example, if you wanted to buy a single call option and the underlying stock every Friday for a month this could be a suitable `strategy` (assuming trading starts on a Monday on business days only):
```jldoctest strategy; output = false
using Bruno: buy, sell
# import strategy to extend the function
import Bruno: strategy

function Bruno.strategy(fin_obj, 
                pricing_model, 
                strategy_mode::Type{ExampleStrategy},
                holdings,
                step;
                kwargs...)

    if step % 5 == 0
        # buy one FinancialInstrument every 5 days with no transaction costs
        buy(fin_obj, 1, holdings, pricing_model, 0) 
        # buy one Stock every 5 days
        buy(fin_obj.widget, 1, holdings, pricing_model, 0) 
    end

    return holdings
end

# output

```

## Running the `strategy` Using `strategy_returns`
All financial instruments and historic and future prices for the underlying widgets must be initialized prior to running the trading strategy. 

```@meta
DocTestSetup = quote
    using Random
    Random.seed!(7)
end
```

```jldoctest strategy; output = false
# create a random array to act as historic prices
historic_prices = rand(50:75, 40)

# create stock from daily historic prices
stock = Stock(;
    prices=historic_prices, 
    name="example_stock", 
    timesteps_per_period = 252
)

# create a random array to act as simulated future prices
future_prices = rand(70:80, 25)

# create European stock call option
option = EuroCallOption(stock, 60)

# run the strategy for 20 days assuming all prices are daily
cumulative_returns, holdings = strategy_returns(
    option, 
    BlackScholes, 
    ExampleStrategy,
    future_prices, 
    20, 
    252
)

# output

(0.3370435884062317, Dict("example_stock" => [0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0  …  2.0, 2.0, 2.0, 3.0, 3.0, 3.0, 3.0, 3.0, 4.0, 0.0], "" => [0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0  …  2.0, 2.0, 2.0, 3.0, 3.0, 3.0, 3.0, 3.0, 4.0, 0.0], "cash" => [0.0, 0.0, 0.0, 0.0, 0.0, -140.4561293636026, -140.4561293636026, -140.4561293636026, -140.4561293636026, -140.4561293636026  …  -265.320912818288, -265.320912818288, -265.320912818288, -401.866828586304, -401.866828586304, -401.866828586304, -401.866828586304, -401.866828586304, -533.5286447658507, 0.3370435884062317]), EuroCallOption{Stock{Int64, Int64, Float64}, Float64, Float64}(Stock{Int64, Int64, Float64}([57, 75, 65, 75, 53, 53, 54, 67, 57, 51  …  75, 80, 79, 77, 76, 76, 80, 73, 75, 76], "example_stock", 252, 2.2609836569660278), 60.0, 0.9206349206349209, 0.02, "", Dict("BlackScholes" => Dict("value" => 57.466422088564244))))

```

```@meta
DocTestSetup = nothing
```

`strategy_returns` returns:
* The cumulative returns that would have been earned after selling any remaining `Widget` or `FinancialInstrument` holdings left over after the strategy runs for the specified length.
* A time series of how much of each object was owned during simulation.
* The updated financial objects after the strategy (maturity and volatilities will likely be different).
