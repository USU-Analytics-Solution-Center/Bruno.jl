using Statistics: std
# place to put all widgets, or assets that don't need a model for the base value. 
# examples: oil, stocks, etc.
"""
Widgets are the root asset at the heart of the package. A 'widget' can be any 
real world financial object such as a stock or commodity. For a list of possible subtypes 
use `subtypes(Widget)`.
"""
abstract type Widget end

# ------ Stocks ------
""" 
    Stock <: Widget

Widget subtype. Used as a base or root asset for financial instrument.
"""
struct Stock{T, TI, TF} <: Widget
    prices::Vector{T}
    name::String
    timesteps_per_period::TI
    volatility::TF

    # constructor for kwargs

    function Stock{T,TI,TF}(;
        prices,
        name = "",
        timesteps_per_period = length(prices),
        volatility = get_volatility(prices, timesteps_per_period),
        _...
    ) where {T,TI,TF}
        # allows single price input through kwargs (and ordered arguments)
        if !isa(prices, Vector)
            prices >= 0 ? prices = [prices] :
            error("Single price point must be non-negative")
            volatility == nothing ?
            error("When using single value input for prices must specify volatility") :
            nothing
        end
        size(prices)[1] > 0 ? nothing : error("Prices cannot be an empty vector")
        # catch nothing volatility from get_volatility()
        volatility == nothing ? error("Volatility cannot be nothing") : nothing
        # catch negative volatility
        volatility >= 0 ? nothing : error("volatility must be non negative")
        # catch negative timesteps_per_period
        timesteps_per_period >= 0 ? nothing : 
        error("timesteps_per_period cannot be negative")
	new{T,TI,TF}(prices, name, timesteps_per_period, volatility)
    end

    # constructor for ordered argumentes 
    function Stock{T,TI,TF}(
        prices,
        name = "",
        timesteps_per_period = length(prices),
        volatility = get_volatility(prices, timesteps_per_period)
    ) where {T,TI,TF}
        if !isa(prices, Vector)
            prices >= 0 ? prices = [prices] :
            error("Single price point must be non-negative")
            volatility == nothing ?
            error("When using single value input for prices must specify volatility") :
            nothing
        end
        size(prices)[1] > 0 ? nothing : error("Prices cannot be an empty vector")
        # catch nothing volatility from get_volatility()
        volatility == nothing ? error("Volatility cannot be nothing") : nothing
        # catch negative volatility
        volatility >= 0 ? nothing : error("volatility must be non negative")
        timesteps_per_period >= 0 ? nothing : 
        # catch negative timesteps_per_period
        error("timesteps_per_period cannot be negative")
	new{T,TI,TF}(prices, name, timesteps_per_period, volatility)
    end
end

# outer constructor to make a stock with a (static) single price
"""
    Stock(prices, name, timesteps_per_period, volatility)
    Stock(price; kwargs...)
    Stock(;kwargs)

Construct a Stock type to use as a base asset for FinancialInstrument.

## Arguments
- `prices`:Historical prices (input as a 1-D array) or the current price input as a number `<: Real`
- `name::String`: Name of the stock or stock ticker symbol. Default "".
- `timesteps_per_period::Int64`: For the size of a timestep in the data, the number of 
time steps for a given period of time, cannot be negative. For example, if the period of 
interest is a year, and daily stock data is used, `timesteps_per_period=252`. Defualt is 
length of the `prices` array or 0 for single price (static) stock. 
Note: If `timesteps_per_period=0`, the Stock represents a 'static' element and cannot be 
used in the `strategy_returns()` method.
- `volatility`: Return volatility, measured in the standard deviation of continuous returns.
Defaults to using `get_volatility()` on the input `prices` array. Note: if a single number 
is given for `prices` volatility must be given.

## Examples
```julia
Stock([1,2,3,4,5], "Example", 252, .05)

kwargs = Dict(
    :prices => [1, 2, 3, 4, 5], 
    :name => "Example", 
    :timesteps_per_period => 252, 
    :volatility => .05
);

Stock(;kwargs...)

Stock(40; volatility=.05)
```
"""
function Stock(price; name = "", volatility)
    prices = [price]
    T = typeof(price)
    TI = Int16
    return Stock{T,TI,T}(; prices = prices, name = name, volatility = volatility, timesteps_per_period = 0)
end

# outer constructor to infer the type used in the prices array
function Stock(
    prices::Vector,
    name = "",
    timesteps_per_period = length(prices),
    volatility = get_volatility(prices, timesteps_per_period)
)
    T = eltype(prices)
    TI = typeof(timesteps_per_period)
    TF = typeof(volatility)
    return Stock{T,TI,TF}(prices, name, timesteps_per_period, volatility)
end
function Stock(;
        prices,
        name = "",
        timesteps_per_period = length(prices),
        volatility = get_volatility(prices, timesteps_per_period),
        _...
)
    T = eltype(prices)
    TI = typeof(timesteps_per_period)
    TF = typeof(volatility)
    return Stock{T,TI,TF}(prices, name, timesteps_per_period, volatility)
end
# ------ Commodities ------
""" 
    Commodity <: Widget

Widget subtype. Used as a base or root asset for FinancialInstrument.
"""
struct Commodity{T, TI, TF} <: Widget
    prices::Vector{T}
    name::String
    timesteps_per_period::TI
    volatility::TF

    # constructor for kwargs

    function Commodity{T,TI,TF}(;
        prices,
        name = "",
        timesteps_per_period = length(prices),
        volatility = get_volatility(prices, timesteps_per_period),
        _...
    ) where {T,TI,TF}
        # allows single price input through kwargs (and ordered arguments)
        if !isa(prices, Vector)
            prices >= 0 ? prices = [prices] :
            error("Single price point must be non-negative")
            volatility == nothing ?
            error("When using single value input for prices must specify volatility") :
            nothing
        end
        size(prices)[1] > 0 ? nothing : error("Prices cannot be an empty vector")
        # catch nothing volatility from get_volatility()
        volatility == nothing ? error("Volatility cannot be nothing") : nothing
        # catch negative volatility
        volatility >= 0 ? nothing : error("volatility must be non negative")
        # catch negative timesteps_per_period
        timesteps_per_period >= 0 ? nothing : 
        error("timesteps_per_period cannot be negative")
	new{T,TI,TF}(prices, name, timesteps_per_period, volatility)
    end

    # constructor for ordered argumentes 
    function Commodity{T,TI,TF}(
        prices,
        name = "",
        timesteps_per_period = length(prices),
        volatility = get_volatility(prices, timesteps_per_period)
    ) where {T,TI,TF}
        if !isa(prices, Vector)
            prices >= 0 ? prices = [prices] :
            error("Single price point must be non-negative")
            volatility == nothing ?
            error("When using single value input for prices must specify volatility") :
            nothing
        end
        size(prices)[1] > 0 ? nothing : error("Prices cannot be an empty vector")
        # catch nothing volatility from get_volatility()
        volatility == nothing ? error("Volatility cannot be nothing") : nothing
        # catch negative volatility
        volatility >= 0 ? nothing : error("volatility must be non negative")
        timesteps_per_period >= 0 ? nothing : 
        # catch negative timesteps_per_period
        error("timesteps_per_period cannot be negative")
	new{T,TI,TF}(prices, name, timesteps_per_period, volatility)
    end
end


# outer constructor to make a Commodity with a (static) single price
"""
    Commodity(prices, name, timesteps_per_period, volatility)
    commodity(price; kwargs...)
    Commodity(;kwargs)

Construct a Commodity type to use as a base asset for FinancialInstrument.

## Arguments
- `prices`:Historical prices (input as a 1-D array) or the current price input as a number `<: Real`
- `name`: String name of the commodity or commodity ticker symbol. Default "".
- `timesteps_per_period`: For the size of a timestep in the data, the number of 
time steps for a given period of time, cannot be negative. For example, if the period of 
interest is a year, and daily commodity price data is used, `timesteps_per_period=252`. 
Defualt is the length of the `prices` array or 0 for a single price (static) Commodity. 
Note: If `timesteps_per_period=0`, the Commodity represents a 'static' element and cannot 
be used in the `strategy_returns()` method.
- `volatility`: Return volatility, measured in the standard deviation of continuous returns.
Defaults to using `get_volatility()` on the input `prices` array. Note: if a single number 
is given for `prices` volatility must be given.

## Examples
```julia
Commodity([1,2,3,4,5], "Example", 252, .05)

kwargs = Dict(
    :prices => [1, 2, 3, 4, 5], 
    :name => "Example", 
    :timesteps_per_period => 252, 
    :volatility => .05
);

Commodity(;kwargs...)

Commodity(40; volatility=.05)
```
"""
function Commodity(price; name = "", volatility)
    prices = [price]
    T = typeof(price)
    TI = Int16
    return Commodity{T,TI,T}(; prices = prices, name = name, volatility = volatility, timesteps_per_period = 0)
end

# outer constructor to infer the type used in the prices array
function Commodity(
    prices::Vector,
    name = "",
    timesteps_per_period = length(prices),
    volatility = get_volatility(prices, timesteps_per_period)
)
    T = eltype(prices)
    TI = typeof(timesteps_per_period)
    TF = typeof(volatility)
    return Commodity{T,TI,TF}(prices, name, timesteps_per_period, volatility)
end
function Commodity(;
        prices,
        name = "",
        timesteps_per_period = length(prices),
        volatility = get_volatility(prices, timesteps_per_period),
        _...
)
    T = eltype(prices)
    TI = typeof(timesteps_per_period)
    TF = typeof(volatility)
    return Commodity{T,TI,TF}(prices, name, timesteps_per_period, volatility)
end

# ---------- Bonds -----------------
""" 
    Bond <: Widget

Widget subtype. Used as a base or root asset for FinancialInstrument.
"""
struct Bond{T,TF} <: Widget
    prices::Array{T}
    name::String
    time_mat::TF
    coupon_rate::TF

    # constructor for kwargs
    function Bond{T,TF}(; prices, name = "", time_mat = 1, coupon_rate = 0.03, _...) where {T,TF}
        size(prices)[1] > 0 ? nothing : error("Prices cannot be an empty vector")
        time_mat > 0 ? nothing : error("time_mat must be positive")
	new{T,TF}(prices, name, time_mat, coupon_rate)
    end

    # constructor for ordered argumentes 
    function Bond{T,TF}(prices, name = "", time_mat = 1, coupon_rate = 0.03) where {T,TF}
        size(prices)[1] > 0 ? nothing : error("Prices cannot be an empty vector")
        time_mat > 0 ? nothing : error("time_mat must be positive")
	new{T,TF}(prices, name, time_mat, coupon_rate)
    end
end

# outer constructor to make a Bond with a (static) single price
"""
    Bond(prices, name, time_mat, coupon_rate)
    Bond(price; kwargs...)
    Bond(;kwargs)

Construct a Bond type to use as a base asset for FinancialInstrument.

## Arguments
- `prices`:Historical prices (input as a 1-D array) or the current price input as a number `<: Real`
- `name`: String name of the Bond or issuing company. Default "".
- `time_mat`: Time until the bond expires (matures) in years. Default 1.
- `coupon_rate`: The coupon rate for the bond. Default .03.

## Examples
```julia
Bond([1,2,3,4,5], "Example", .5, .05)

kwargs = Dict(:prices => [1, 2, 3, 4, 5], :name => "Example", :time_mat => .5, :coupon_rate => .05);
Bond(;kwargs...)

Bond(2; coupon_rate=.05)
```
"""
function Bond(price; name = "", time_mat = 1, coupon_rate = 0.03)
    prices = [price]
    T = typeof(price)
    time_mat, coupon_rate = promote(time_mat, coupon_rate)
    TF = typeof(coupon_rate)
    return Bond{T,TF}(; prices = prices, name = name, time_mat = time_mat, coupon_rate = coupon_rate)
end

# outer constructor with implied type of prices vector 
function Bond(; prices, name = "", time_mat = 1, coupon_rate = 0.03, _...)
    T = eltype(prices)
    time_mat, coupon_rate = promote(time_mat, coupon_rate)
    TF = typeof(coupon_rate)
    return Bond{T,TF}(prices, name, time_mat, coupon_rate)
end
function Bond(prices::Vector, name = "", time_mat = 1, coupon_rate = 0.03)
    T = eltype(prices)
    time_mat, coupon_rate = promote(time_mat, coupon_rate)
    TF = typeof(coupon_rate)
    return Bond{T,TF}(prices, name, time_mat, coupon_rate)
end
# Helpers 
"""
    get_volatility(prices)

Finds the standard deviation of continuous returns for an array of prices.
"""

function get_volatility(prices::Vector, timesteps_per_period)
    length(prices) > 2 ? nothing :
    # need at least three values so std can work
    return error("Must have at least three values to calculate the volatility")  
    returns = [((prices[i+1] - prices[i]) / prices[i]) + 1 for i = 1:(length(prices)-1)]
    cont_return = log.(returns)
    std(cont_return, corrected = false) * sqrt(timesteps_per_period)
end

get_volatility(prices) = get_volatility(prices, length(prices))

# to make positional arguments work
get_volatility(prices, timesteps_per_period) = nothing

function add_price_value(a_widget::Widget, a_new_price)
    a_new_price >= 0 ? nothing :
    @warn("You are trying to add a negative number to a prices list")
    push!(a_widget.prices, a_new_price)
end

function get_prices(a_widget::Widget)
    a_widget.prices
end
