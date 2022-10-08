using Statistics: std
# place to put all widgets, or assets that don't need a model for the base value. 
# examples: oil, stocks, etc.
"""
Widgets are the root asset at the heart of the package. A 'Widget' can be any 
real world finicial object such as a stock, or commodity. For a list of possible subtypes 
use `subtypes(Widget)`
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
        # catch nothing volatility from get_volatility()
        volatility == nothing ? error("Volatility cannot be nothing") : nothing
        # catch negative volatility
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
        # catch nothing volatility from get_volatility()
        volatility == nothing ? error("Volatility cannot be nothing") : nothing
        # catch negative volatility
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
- `prices`:Historical prices (input as a 1-D array) or the current price input as a number `<: Real`
- `name::String`: Name of the stock or stock ticker symbol. Default "".
- `volatility`: Return volatility, measured in the standard deviation of continuous returns.
Defaults to using `get_volatility()` on the input `prices` array. Note: if a single number 
is given for `prices` volatility must be given.

## Examples
```jldoctest
julia> Stock([1,2,3,4,5], "Test", .05)
Stock(AbstractFloat[1.0, 2.0, 3.0, 4.0, 5.0], "Test", 0.05)

julia> kwargs = Dict(:prices=>[1,2,3,4,5], :name=>"Test", :volatility=>.05)
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
        # catch nothing volatility from get_volatility()
        volatility == nothing ? error("Volatility cannot be nothing") : nothing
        # catch negative volatility
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
        # catch nothing volatility from get_volatility()
        volatility == nothing ? error("Volatility cannot be nothing") : nothing
        # catch negative volatility
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
- `prices`:Historical prices (input as a 1-D array) or the current price input as a number `<: Real`
- `name::String`: Name of the commodity or commodity ticker symbol. Default "".
- `volatility`: Return volatility, measured in the standard deviation of continuous returns.
Defaults to using `get_volatility()` on the input `prices` array. Note: if a single number 
is given for `prices` volatility must be given.

## Examples
```jldoctest
julia> Commodity([1,2,3,4,5], "Test", .05)
Commodity(AbstractFloat[1.0, 2.0, 3.0, 4.0, 5.0], "Test", 0.05)

julia> kwargs = Dict(:prices=>[1,2,3,4,5], :name=>"Test", :volatility=>.05)
julia> Commodity(;kwargs...)
Commodity(AbstractFloat[1.0, 2.0, 3.0, 4.0, 5.0], "Test", 0.05)

julia> Commodity(40; volatility=.05)
Commodity(AbstractFloat[40.0], "", 0.05)
```
"""
function Commodity(price::Real; name = "", volatility)
    prices = [price]
    Commodity(;prices = prices, name = name , volatility = volatility)
end

# ---------- Bonds -----------------
""" 
    Bond <: Widget

Widget subtype. Used as a base or root asset for FinancialInstrument
"""
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
"""
    Bond(prices, name, time_mat, coupon_rate)
    Bond(;kwargs)
    Bond(price; kwargs)

Construct a Bond type to use as a base asset for FinancialInstrument.

## Arguments
- `prices`:Historical prices (input as a 1-D array) or the current price input as a number `<: Real`
- `name::String`: Name of the Bond or issuing company. Default "".
- `time_mat`: Time until the bond expires (matures) in years. Default 1.
- `coupon_rate`: The coupon rate for the bond. Default .03.

## Examples
```jldoctest
julia> Bond([1,2,3,4,5], "Test", .5, .05)
Bond(AbstractFloat[1.0, 2.0, 3.0, 4.0, 5.0], "Test", 0.5, 0.05)

julia> kwargs = Dict(:prices=>[1,2,3,4,5], :name=>"Test", :time_mat=>.5, :coupon_rate=>.05)
julia> Bond(;kwargs...)
Bond(AbstractFloat[1.0, 2.0, 3.0, 4.0, 5.0], "Test", 0.5, 0.05)

julia> Bond(2; coupon_rate=.05)
Bond(2.0, "", 1, 0.05)
```
"""
function Bond(price::Real; name="", time_mat=1, coupon_rate=.03)
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