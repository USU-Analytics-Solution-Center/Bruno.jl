using Statistics: std
# place to put all widgets, or assets that don't need a model for the base value. 
# examples: oil, stocks, etc.
"""
## Description
Widgets are the root asset at the heart of the package. A 'Widget' can be any 
real world finicial object such as a stock, or commodity. 

## Syntax for Kwargs
```
kwargs = (prices=prices, name="APPL")
a_widget = Widget(;kwargs...)
```

## Syntax for ordered argumentes
```
a_widget = Widget(prices=[1, 2, 3, 4, 5], name ="Example", volatility =.3)
```

"""
abstract type Widget end

# ------ Stocks ------
""" 
    Stock <: Widget

Widget subtype. Used as a base or root asset for FinancialInstrument
"""
struct Stock <: Widget 
    prices::Array{AbstractFloat}
    name::String
    volatility::AbstractFloat
    
    # constructor for kwargs
    function Stock(; prices, name="", volatility=get_volatility(prices), _...)
        # allows single price input through kwargs (and ordered arguments)
        if typeof(prices) <: Real 
            prices >= 0 ? prices = [prices] : error("Single price point must be non-negative")
            volatility == nothing ? 
                error("When using single value input for prices must specify volatility") :
                nothing
        end
        size(prices)[1] > 0 ? nothing : error("Prices cannot be an empty vector")
        volatility >= 0 ? nothing : error("volatility must be non negative")
        new(prices, name, volatility)
    end

    # constructor for ordered argumentes 
    function Stock(prices, name = "", volatility = get_volatility(prices))  
        if typeof(prices) <: Real 
            prices >= 0 ? prices = [prices] : error("Single price point must be non-negative")
            volatility == nothing ? 
                error("When using single value input for prices must specify volatility") :
                nothing
        end
        size(prices)[1] > 0 ? nothing : error("Prices cannot be an empty vector")
        volatility >= 0 ? nothing : error("volatility must be non negative")
        new(prices, name, volatility)
    end
end

# outer constructor to make a stock with a (static) single price
"""
    Stock(prices, name, volatility)
    Stock(;kwargs)
    Stock(price; kwargs)

Construct a Stock type to use as a base asset for FinancialInstrument.

## Arguments
- `prices`:Historical prices (input as a 1-D array) or the current price input as a number
`<: Real`
- `name::String`: Name of the stock or stock ticker symbol. Default "".
- `volatility`: Return volatility, measured in the standard deviation of continuous returns.
Defaults to using `get_volatility()` on the input `prices` array. Note: if a single number 
is given for `prices` volatility must be given.

## Examples
```jldoctest
julia> Stock([1,2,3,4,5], "Test", .05)
Stock(AbstractFloat[1.0, 2.0, 3.0, 4.0, 5.0], "Test", 0.05)

julia> kwargs = Dict(prices=>[1,2,3,4,5], name=>"Test", volatility=>.05)
julia> Stock(;kwargs...)
Stock(AbstractFloat[1.0, 2.0, 3.0, 4.0, 5.0], "Test", 0.05)

julia> Stock(40; volatility=.05)
Stock(AbstractFloat[40.0], "", 0.05)
```
"""
function Stock(price::Real; name = "", volatility)
    prices = [price]
    Stock(;prices = prices, name = name , volatility = volatility)
end

# ------ Commodities ------
""" 
    Commodity <: Widget

Widget subtype. Used as a base or root asset for FinancialInstrument
"""
struct Commodity <: Widget
    prices::Array{AbstractFloat}
    name::String
    volatility::AbstractFloat

    # constructor for kwargs
    function Commodity(; prices, name = "", volatility = get_volatility(prices), _...)
        # allows for single number input for prices
        if typeof(prices) <: Real 
            prices >= 0 ? prices = [prices] : error("Single price point must be non-negative")
            volatility == nothing ? 
                error("When using single value input for prices must specify volatility") :
                nothing
        end
        size(prices)[1] > 0 ? nothing : error("Prices cannot be an empty vector")
        volatility >= 0 ? nothing : error("volatility must be non negative")
        new(prices, name, volatility)
    end

    # constructor for ordered argumentes 
    function Commodity(prices, name = "", volatility = get_volatility(prices))  
        if typeof(prices) <: Real 
            prices >= 0 ? prices = [prices] : error("Single price point must be non-negative")
            volatility == nothing ? 
                error("When using single value input for prices must specify volatility") :
                nothing
        end
        size(prices)[1] > 0 ? nothing : error("Prices cannot be an empty vector")
        volatility >= 0 ? nothing : error("volatility must be non negative")
        new(prices, name, volatility)
    end
end

# outer constructor to make a Commodity with a (static) single price
"""
    Commodity(prices, name, volatility)
    Commodity(;kwargs)
    Commodity(price; kwargs)

Construct a Commodity type to use as a base asset for FinancialInstrument.

## Arguments
- `prices`:Historical prices (input as a 1-D array) or the current price input as a number
`<: Real`
- `name::String`: Name of the commodity or commodity ticker symbol. Default "".
- `volatility`: Return volatility, measured in the standard deviation of continuous returns.
Defaults to using `get_volatility()` on the input `prices` array. Note: if a single number 
is given for `prices` volatility must be given.

## Examples
```jldoctest
julia> Commodity([1,2,3,4,5], "Test", .05)
Commodity(AbstractFloat[1.0, 2.0, 3.0, 4.0, 5.0], "Test", 0.05)

julia> kwargs = Dict(prices=>[1,2,3,4,5], name=>"Test", volatility=>.05)
julia> Commodity(;kwargs...)
Commodity(AbstractFloat[1.0, 2.0, 3.0, 4.0, 5.0], "Test", 0.05)

julia> Commodity(40; volatility=.05)
Commodity(AbstractFloat[40.0], "", 0.05)
```
"""
function Commodity(price::AbstractFloat; name = "", volatility)
    prices = [price]
    Commodity(;prices = prices, name = name , volatility = volatility)
end

# bonds
struct Bond <: Widget
    prices::Array{AbstractFloat}
    name::String
    time_mat::AbstractFloat
    coupon_rate::AbstractFloat

    # constructor for kwargs
    function Bond(; prices, name="", time_mat=1, coupon_rate=.03, _...)
        size(prices)[1] > 0 ? nothing : error("Prices cannot be an empty vector")
        time_mat > 0 ? nothing : error("time_mat must be positive")
        new(prices, name, time_mat, coupon_rate)
    end

    # constructor for ordered argumentes 
    function Bond(prices, name="", time_mat=1, coupon_rate=.03)  
        size(prices)[1] > 0 ? nothing : error("Prices cannot be an empty vector")
        time_mat > 0 ? nothing : error("time_mat must be positive")
        new(prices, name, time_mat, coupon_rate)
    end
end

# outer constructor to make a Bond with a (static) single price
function Bond(price::AbstractFloat; name="", time_mat=1, coupon_rate=.03)
    prices = [price]
    Bond(;prices=prices, name=name , time_mat=time_mat, coupon_rate=coupon_rate)
end

# Helpers 
"""
    get_volatility(prices)

Finds the standard deviation of continuous returns for an array of prices
"""
function get_volatility(prices) 
    length(prices) > 1 ? nothing : return nothing
    returns = [((prices[i+1] - prices[i]) / prices[i]) + 1 for i in 1:(length(prices) - 1)]
    cont_return = log.(returns)
    std(cont_return) 
end