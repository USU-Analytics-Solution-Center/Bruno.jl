# Hedging/ Trading strategy testing

## Overview
`strategy_returns()` can back test a trading strategy or test a strategy on simulated future data. 

This tutorial shows how to create a simple trading strategy simulation. It demonstrates 
* How to create a new type to allow for julia's [multiple dispatch](https://docs.julialang.org/en/v1/manual/methods/) on the `strategy()` function
* How to create a new method for the `strategy` function
* How to use `strategy_returns` to run the strategy on randomly simulated data

## Create new `Hedging` type
Each new strategy will need a new type to allow for dispatch. Use this type for `strategy_mode` argument in `strategy_returns`

```
using Bruno

# creating a new subtype for dispatch
primitive type ExampleStrategy <: Hedging 8 end
```

## Create a new `strategy` method
`strategy` is the core function in `strategy_returns`. It will need a new method for each different strategy. `strategy` and `strategy_returns` both work for a single `FinancialInstrument` or for a `vector{<:FinancialInstrument}`, but it needs to be explicit in the function definition. `buy` and `sell` functions are provided to make writing strategies easier.
For example, if you wanted to buy a single call option and the underlying stock every Friday for a month this could be a suitable `strategy` (assuming trading starts on a Monday on business days only):
```
using Bruno: buy, sell
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
```

## Running the `strategy` using `strategy_returns`
All FinancialInstruments and prices to be used must be initialized prior to running the trading strategy. 

```
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
```

`strategy_returns` returns the cumulative returns that would have been earned after selling any remaining `Widget` or `FinancialInstrument` holdings left over after the strategy runs for the specified length and a time series of how much of each object was owned during simulation.