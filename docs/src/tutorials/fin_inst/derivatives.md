# Derivatives (and Other Financial Instruments)

## Overview
[Financial instruments](@ref Fin_instruments) are financial tools that depend on an underlying asset (or eventually more than one). Common examples are call and put options on stocks and commodities. They can be used in combination with both the `price!` and the `strategy_returns` functions.

## Creating a stock option
Here's how to create a stock `Option` (more specifically a European Call Option). To do that, we need to make a stock first. You can find a tutorial [here](@ref widget_tutorial).

```jldoctest derivative; output = false, setup = :(using Bruno)
historical_prices = [1.0, 2.0, 3.0, 4.0, 5.0]

# creates a Stock widget assuming historical prices are daily prices
a_widget = Stock(;prices=historical_prices, name="my_widget", timesteps_per_period=252)

# creates a call option with a strike price of $60
call = EuroCallOption(a_widget, 60)

# output

EuroCallOption{Stock{Float64, Int64, Float64}, Float64, Float64}(Stock{Float64, Int64, Float64}([1.0, 2.0, 3.0, 4.0, 5.0], "my_widget", 252, 2.8600161683167746), 60.0, 1.0, 0.02, "", Dict{String, Dict{String, Float64}}())
```

## Interacting With a Financial Instrument (Asset Pricing)
One of the more interesting things that can be done with financial instruments is asset pricing with several models. Not all of the models work with all the financial instruments, so check the [manual](@ref pricing_fin_inst) to see if it is supported and a method is written for each model.

```jldoctest derivative; output = false, setup = :(using Bruno)
# pricing the EuroCallOption from above
# values will be written to values_library in the option
price!(call, BlackScholes)

# accessing the value from values_library
call.values_library["BlackScholes"]["value"]

# output

2.930783603632026
```
