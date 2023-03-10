# Hedging/Trading Strategy testing

## [`strategy`](@ref) Function 
The [`strategy`](@ref) function is the backbone of the `strategy_returns` function. To test out a trading strategy, `strategy` must be extended and given a new method overload for a new `Hedging` type. 

The key elements to defining a new `strategy` are (in the order used by `strategy_returns`):
* `fin_obj`: the `FinancialInstrument` (or `Vector{:>FinancialInstrument}` the strategy is defined for. In the function definition, it can be left without a type to be generic for any `FinancialInstrument`. 
* `pricing_model`: the pricing model to be used on the financial instruments in the strategy. It does not need to be specified in the function definition. 
* `holdings`: The dictionary of owned financial instruments and `Widgets`. Does not need to be specified in the function definition.
* `step`: The index of time steps that have passed in the strategy simulation. Does not need to be specified in the function definition. 
* `kwargs...`: A place holder to allow pass through keyword arguments that might be needed in the strategy such as transaction costs, or extra arguments for the `price!` function. 

IMPORTANT: always `return holdings` at the end of the `strategy` function!!

### `buy` and `sell` Functions
The [`buy`](@ref Bruno.buy) and [`sell`](@ref Bruno.sell) functions are provided to make defining a strategy easier inside the strategy definition. They record in the `holdings` dictionary how much more or less of a certain `FinancialInstrument` or `Widget` are owned after the transaction, along with the changes in the `holdings["cash"]`. 

### Using `holdings` or `step` in a `strategy`
The `holdings` dictionary is initialized during the startup phase of the `strategy_returns` function, but it can be manipulated by a custom `strategy` function in ways other than the `buy` and `sell` functions. 

For example, if tracking the delta exposure of a stock option would be helpful in a strategy, it can be added to the `holdings` dictionary.
```
# inside the custom strategy function
holdings["delta"] = current_delta
```
Then, at the end of the strategy function, `strategy_returns` will copy all of the values to a dictionary of arrays of all the holdings during every time step. This is returned at the end of `strategy_returns`. 

The `step` argument is indexed from the number of timesteps from the start of the strategy. 
`step==1` happens on the timestep of the strategy, before the first entry of `future_prices`. 
This is a good time to set up things for the initial strategy.
For example, if your strategy is to buy one call option then hedge the risk using the underlying stock, the beginning of your `strategy` function might include:

```
# inside strategy function
if step == 1
    buy(fin_obj, 1, holdings, pricing_model, 0) #assuming no transaction cost
end
```

The `step` function can also be used to buy or sell at a specific time interval. See the [tutorial page](@ref strategy_method_tutorial) for an example. 

## [`strategy_returns`](@ref) Function
[`strategy_returns`](@ref) acts as a wrapper for the `strategy` function. It handles all interest on cash balances, and updates the `ts_holdings` object of a time-series of the `holdings` dictionary. 

`timesteps_per_period` reflects the size of time that passes between each time the `strategy` function is called compared to the implicit time period.
For example, if daily data is used for historic and future prices, assuming yearly interest rates, then `timesteps_per_period` would be 252. 
This is to allow `strategy_returns` function to be as generic as possible. Yearly, biyearly, or even hourly time windows are possible depending on the nature of the data used. 

Note: `strategy_returns` returns the dollar cumulative return from the strategy, NOT the percent return on an investment. 