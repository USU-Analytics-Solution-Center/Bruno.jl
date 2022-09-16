# place to put all widgets, or assets that don't need a model for the base value. 
# examples: oil, stocks, etc.

abstract type Widget end

struct Stock <: Widget 
    prices::Array{AbstractFloat}
    name::String
    volatility::AbstractFloat
    # constructor for kwargs
    function Stock(; prices, name = "", volatility = var(prices))
        new(prices, name, volatility)
    end
end

struct Commodity <: Widget
    price::Array{AbstractFloat}
    name::String
end

struct Bond <: Widget
    price::Array{AbstractFloat}
    name::String
    time_mat::AbstractFloat
    coupon_rate::AbstractFloat
end