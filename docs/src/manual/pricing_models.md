# Pricing Models
Pricing models used with the [`price!`](@ref) function all have a corresponding `Model` subtype. Current pricing models supported are `BlackScholes`, `BinomialTree`, `MonteCarlo{<:MonteCarloModel}`, and `StockPrice`.

## [Pricing Base Assets (`Widgets`)](@id pricing_widgets)
All `Widget` subtypes can be priced with any pricing model subtype of `Model`. [`price!`](@ref) returns the last price in the array of the `prices` field. To make code more explicit, the `StockPrice` type may be used which does not have a method for any `Financial Instrument`.  

## [Pricing FinancialInstruments](@id pricing_fin_inst)
Pricing a `FinancialInstrument` with the [`price!`](@ref) function returns the theoretical price and mutates the `values_library` field of the `FinancialInstrument`. `values_library` contains all theoretical prices for the Financial Instrument that have been calculated with the function arguments used in the calculation. 

### Black Scholes Model
The [Black-Scholes-Merton](https://en.wikipedia.org/wiki/Black%E2%80%93Scholes_model) model for pricing European options. 

Use `BlackScholes` with the [`price!`](@ref price!(::Option, ::Type{BlackScholes})). 

Only defined for [`EuroCallOption`](@ref) and [`EuroPutOption`](@ref). 

Example:
pricing a three month European call option

```jldoctest; output = false, setup = :(using Bruno)
# creating a stock
stock = Stock(50.0; volatility=.32)

# creating a 3 month European call option with a $55 strike price 
call = EuroCallOption(;widget=stock, strike_price=55, maturity=.25, risk_free_rate=.02)

call_price = price!(call, BlackScholes)
call_price == call.values_library["BlackScholes"]["value"]

# output

true
```

### Binomial Pricing Model
The [Binomial options pricing model](https://en.wikipedia.org/wiki/Binomial_options_pricing_model). 

Use `BinomialTree` with the [`price!`](@ref price!(::Option, ::Type{BinomialTree})).

Defined for all `Option` subtypes. 

Extra function arguments:
* `tree_depth`: The number of levels or time steps included in the tree. Default is three.
* `delta`: The continuous dividend rate of the underlying stock (or other base asset). Default is zero.

Example:
pricing a three month American call option.

```jldoctest; output = false, setup = :(using Bruno)
# creating a stock
stock = Stock(50.0; volatility=.32)

# creating a 3 month American call option with a $55 strike price 
call = AmericanCallOption(;widget=stock, strike_price=55, maturity=.25, risk_free_rate=.02)

# calculating the options price using 5 time steps in the tree
call_price = price!(call, BinomialTree; tree_depth=5)
call_price == call.values_library["BinomialTree"]["value"]

# output

true
```

### Monte Carlo Pricing Model
[Monte Carlo simulation](https://en.wikipedia.org/wiki/Monte_Carlo_methods_in_finance) valuation for options. Returns the average discounted payoff of the option at the end of the stochasticly simulated time-series. Current possible simulation methods are:

* [Log diffusion model](@ref log_diff_manual) for asset prices. Assumes `Option.risk_free_rate` to be the period drift.
* [Time-series bootstrap](@ref ts_bootstrap_manual) of historic asset returns.

Use `MonteCarlo{T}` with [`price!`](@ref price!(::Option, ::Type{MonteCarlo{LogDiffusion}})) where T is either `LogDiffusion` or `MCBootstrap` type.

Only defined for [`EuroCallOption`](@ref) and [`EuroPutOption`](@ref). For `MCBootstrap`, a static `Widget` cannot be used, `Widget.prices` field must have at least three prices, and `timesteps_per_period` cannot be zero.

Extra function arguments for `LogDiffusion` :
* `n_sims`: The number of simulations to run in the Monte Carlo analysis. Default 100.
* `sim_size`: The number of generated steps in each simulation. Default 100. 

For `MCBootstrap`:
* `n_sims`: The number of simulations to run in the Monte Carlo analysis. Default 100.
* `bootstrap_method`: The type of time-series bootstrap to be used. Possible types are `Stationary`, `CircularBlock`, and `MovingBlock`. Default is `Stationary`. 

Note: values are stored in the `Option.values_library` field with the keys `"MC_LogDiffusion"` and `"MC_Bootstrap{bootstrap_method}"`.

Example:
pricing a three month European call option
```jldoctest; output = false, setup = :(using Bruno)
# creating a stock with a random array for historic prices
historic_prices = rand(45:50, 20)
stock = Stock(;prices = historic_prices)

# creating a 6 month European call option with a $55 strike price 
call = EuroCallOption(stock, 55, .5, .02)

# calculating the options price using log diffusion sim model
mc_logdiff_price = price!(call, MonteCarlo{LogDiffusion}; n_sims=50, sim_size=60)

# calculate the option price using time-series bootstrap
mc_stationary = price!(call, MonteCarlo{MCBootstrap}; n_sims=50, bootstrap_method=Stationary)
mc_circular = price!(call, MonteCarlo{MCBootstrap}; n_sims=50, bootstrap_method=CircularBlock)
mc_movingblock = price!(call, MonteCarlo{MCBootstrap}; n_sims=50, bootstrap_method=MovingBlock)

# accessing the values
mc_logdiff_price == call.values_library["MC_LogDiffusion"]["value"]
mc_stationary == call.values_library["MC_Bootstrap{Stationary}"]["value"]
mc_circular == call.values_library["MC_Bootstrap{CircularBlock}"]["value"]
mc_movingblock == call.values_library["MC_Bootstrap{MovingBlock}"]["value"]

# output

true
```

