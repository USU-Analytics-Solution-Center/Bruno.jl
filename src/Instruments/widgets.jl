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

# stocks
struct Stock <: Widget 
    prices::Array{AbstractFloat}
    name::String
    volatility::AbstractFloat
    
    # constructor for kwargs
    function Stock(; prices, name = "", volatility = get_volatility(prices), _...)
        @assert size(prices)[1] > 0 "Prices cannot be an empty vector"
        new(prices, name, volatility)
    end

    # constructor for ordered argumentes 
    function Stock(prices, name = "", volatility = get_volatility(prices))  
        new(prices, name, volatility)
    end
end

# outer constructor to make a stock with a (static) single price
function Stock(price::Real; name = "", volatility)
    prices = [price]
    Stock(;prices = prices, name = name , volatility = volatility)
end

# Commodities
struct Commodity <: Widget
    prices::Array{AbstractFloat}
    name::String
    volatility::AbstractFloat

    # constructor for kwargs
    function Commodity(; prices, name = "", volatility = get_volatility(prices), _...)
        @assert size(prices)[1] > 0 "Prices cannot be an empty vector"
        new(prices, name, volatility)
    end

    # constructor for ordered argumentes 
    function Commodity(prices, name = "", volatility = get_volatility(prices))  
        new(prices, name, volatility)
    end
end

# outer constructor to make a stock with a (static) single price
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
        @assert size(prices)[1] > 0 "Prices cannot be an empty vector"
        new(prices, name, time_mat, coupon_rate)
    end
end

# Helpers 

function get_volatility(prices) 
    returns = [((prices[i+1] - prices[i]) / prices[i]) + 1 for i in 1:(length(prices) - 1)]
    cont_return = log.(returns)
    std(cont_return) 
end