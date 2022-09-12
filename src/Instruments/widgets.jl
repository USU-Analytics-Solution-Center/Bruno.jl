# place to put all widgets, or assets that don't need a model for the base value. 
# examples: oil, stocks, etc.

abstract type Widget end

struct Stock <: Widget 
    prices::Array{AbstractFloat}
    name::String
    volatility::AbstractFloat
    time_delta::AbstractFloat
end

struct Commodity <: Widget
    price::Array{AbstractFloat}
    name::String
    time_delta::AbstractFloat
end

struct Bond <: Widget
    price::Array{AbstractFloat}
    time_mat::AbstractFloat
    coupon_rate::AbstractFloat
end

