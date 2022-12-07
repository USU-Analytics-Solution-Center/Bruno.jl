# Type System

## Base Assets (Widgets)

### [Creating Widgets](@id creating_widget_manual)
Base assets (`Widgets`) are the building blocks for the rest of the Bruno package. Base assets can be used as stand alone structs or as an underlying asset in a `FinancialInstrument` like an `AmericanCallOption`.

Current `Widget` types Bruno supports are [`Stock`](@ref),  [`Commodity`](@ref) and [`Bond`](@ref). 

#### [`Stock`](@ref Stock(::Real))
Stocks are stock equity issued by a company. 

Stocks can be instantiated using a `Vector` of historic prices, or as a static stock with a single price (assumed to be the current price).

Note: when using testing trading strategies with `strategy_returns` the stock struct cannot be static and must have at least three historic prices. 

When constructing a [`Stock`](@ref Stock(::Real)): 

The `name` field is optional, and only necessary for trading strategy testing using `strategy_returns`.

`timesteps_per_period` reflects the size of time that passes between each price in `Stock.prices` compared to the implicit time period. For example, if daily data is used assuming yearly interest rates and rates of return (as is common) `timesteps_per_period=252`. This is to allow the pricing and strategy testing functions to be as generic as possible. Yearly, biyearly, or even hourly time windows are possible depending on the nature of the data used. 

Examples:
```
# creating an array of prices
historic_prices = collect(40:60)

# creating a Stock with historic prices
# volatility will be automatically calculated
a_stock = Stock(;
    prices=historic_prices, 
    name="stock_1", 
    timesteps_per_period=252
)

# creating a 'static' Stock with a single price
static_stock = Stock(60; volatility=.3, name="static_stock")
```

#### [`Commodity`](@ref Commodity(::Real))
Commodities are raw materials or primary products that can be bought or sold.

Commodity can be instantiated using a `Vector` of historic prices, or as a static commodity with a single price (assumed to be the current price)
Note: When using testing trading strategies with `strategy_returns` the Commodity struct cannot be static and must have at least 3 historic prices.
The `name` field is optional, and only necessary for trading strategy testing using `strategy_returns`.

`timesteps_per_period` is identical to the usage described in the `Stock` struct.

Examples:
```
# creating an array to represent prices
historic_prices = collect(40:60)

# creating a Commodity with historic prices
# volatility will be automatically calculated
a_commodity = Commodity(;
    prices=historic_prices, 
    name="stock_1", 
    timesteps_per_period=252
)

# creating a 'static' Commodity with a single price
static_commodity = Commodity(60; volatility=.3, name="static_stock")
```

#### [`Bond`](@ref Bond(::Real))
Bonds are long term loans issued by companies.

`Bond` structs can theoretically be used currently as an underlying asset in a `FinancialInstrument`. However additional funcitonality is not currently supported in Bruno. Pull requests are welcome!

### Interacting With `Widgets`
Widgets can be used with the [`price!`](@ref)function however, unlike most `FinancialInstruments`, the `price!` function will dispatch to return the last number in the `prices` array of the `Widget` struct. This is the assumed current market price for the `Widget`. Widgets can also be used in trading strategies with [`strategy_returns`](@ref)

## Financial Instruments 

### [Creating a Financial Instrument](@id creating_fin_inst)
Financial instruments are financial tools that depend on one or more underlying assets. Current [`FinancialInstrument`](@ref) types are: [`Option`](@ref) and [`Future`](@ref).

Concrete struct subtypes of `Option` are 
* [`EuroCallOption`](@ref EuroCallOption(::Widget, ::Real))
* [`EuroPutOption`](@ref EuroPutOption(::Widget, ::Real))
* [`AmericanCallOption`](@ref AmericanCallOption(::Widget, ::Real))
* [`AmericanPutOption`](@ref AmericanPutOption(::Widget, ::Real))

Each struct has a robust [constructor](@ref Fin_inst_constructors) function to instantiate a new `Option`.

The `values_library` field holds a dictionary of computed prices for the `FinancialInstrument`. Using the [`price!`](@ref) function mutates the library and adds a computed value for the used pricing model and arguments. See [pricing financial instruments](@ref pricing_fin_inst) for more information.

Note: the `maturity` and `risk_free_rate` fields are both in terms of the implicit time period. So, if yearly APR interest rates are used, then the implicit time period is a year and both `maturity` and `risk_free_rate` should be in terms of years. 

### Interacting With `FinancialInstruments`
Financial instruments can be priced using the [`price!`](@ref) as well as used to test trading and hedging strategies using the [`strategy_returns`](@ref) function.
