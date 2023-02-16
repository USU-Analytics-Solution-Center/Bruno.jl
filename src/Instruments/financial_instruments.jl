# financial instruments that can be passed to simulate. They house underlying widgets as part
# of the insturment. Ex: Stock call options house an underlying stock
"""FinancialInstrument is the supertype for any instrument that uses a base asset
(widget) in its definition (like a financial derivative)."""
abstract type FinancialInstrument end

# ----- Type system for options: subtype of FinancialInstrument ------
"""
    Option <: FinancialInstrument

Abstract FinancialInstrument subtype. Supertype of all options contract types.
"""
abstract type Option <: FinancialInstrument end

# ----- Abstract type for all call and put options -----
"""
    CallOption{T <: Widget} <: Option

Abstract option subtype. Super type for all call options types.
"""
abstract type CallOption{T<:Widget} <: Option end
"""
    PutOption{T <: Widget} <: Option

Abstract option subtype. Super type for all put options types.
"""
abstract type PutOption{T<:Widget} <: Option end

# ----- Concrete types for Euro and American call options
"""
    EuroCallOption{T <: Widget} <: CallOption{T}

European call option with underlying asset `T`. 
"""
struct EuroCallOption{T<:Widget,S,D} <: CallOption{T}
    widget::T
    strike_price::S
    maturity::S
    risk_free_rate::S
    label::String
    values_library::Dict{String,Dict{String,D}}

    # kwargs constructor
    function EuroCallOption{T,S,D}(;
        widget,
        strike_price = widget.prices[end],
        maturity = 1,
        risk_free_rate = 0.02,
        label = "",
        values_library = Dict{String,Dict{String,D}}(),
    ) where {T<:Widget,S,D}
        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity >= 0 ? nothing : error("maturity must be positive ", maturity)
        values_library == Dict{String,Dict{String,D}}() ? nothing :
        @warn("It is not recommended to pass values through the constructor. \
        price!(Instrument, pricing_model) should be used")
        new{T,S,D}(widget, strike_price, maturity, risk_free_rate, label, values_library)
    end

    # ordered arguments constructor
    function EuroCallOption{T,S,D}(
        widget,
        strike_price,
        maturity,
        risk_free_rate,
        label,
        values_library,
    ) where {T<:Widget,S,D}
        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity >= 0 ? nothing : error("maturity must be positive")
        values_library == Dict{String,Dict{String,D}}() ? nothing :
        @warn("It is not recommended to pass values through the constructor. \
        price!(Instrument, pricing_model) should be used")
        new{T,S,D}(widget, strike_price, maturity, risk_free_rate, label, values_library)
    end
end

# Outer constructors for passing only the widget
"""
    EuroCallOption(;kwargs...)
    EuroCallOption{T<:Widget}(;kwargs...)
    EuroCallOption{T<:Widget}(widget, strike_price, maturity, risk_free_rate, values_library)

Construct a EuroCallOption with underlying asset `T`.

## Arguments
- `widget`: underlying asset
- `strike_price`: Contracted price to buy underlying asset at maturity
- `maturity`: time to maturity of the option with respect to implicit time period. Default 1.
- `risk_free_rate`: market risk free interest rate. Default is .02.
- `values_library`: A dictionary of values returned from pricing functions. Default initializes
to an empty dictionary. use `price!()` function to load theoretical option prices.

## Examples
```julia
stock = Stock([1,2,4,3,5,3]);

EuroCallOption(stock, 10)

kwargs = Dict(:widget=>stock, :strike_price=>10, :maturity=>1, :risk_free_rate=>.02);
EuroCallOption(;kwargs...)
```
"""
function EuroCallOption(
    widget,
    strike_price = widget.prices[end],
    maturity = 1,
    risk_free_rate = 0.02,
    label = "",
    values_library = Dict{String,Dict{String,Float64}}(),
)
    T = typeof(widget)
    strike_price, maturity, risk_free_rate = promote(strike_price, maturity, risk_free_rate)
    S = typeof(strike_price)
    D = valtype(valtype(values_library))

    return EuroCallOption{T,S,D}(widget, strike_price, maturity, risk_free_rate, label, values_library)
end

function EuroCallOption(;
    widget,
    strike_price = widget.prices[end],
    maturity = 1,
    risk_free_rate = 0.02,
    label = "",
    values_library = Dict{String,Dict{String,Float64}}()
)
    T = typeof(widget)
    strike_price, maturity, risk_free_rate = promote(strike_price, maturity, risk_free_rate)
    S = typeof(strike_price)
    D = valtype(valtype(values_library))

    return EuroCallOption{T,S,D}(widget, strike_price, maturity, risk_free_rate, label, values_library)
end

"""
    AmericanCallOption{T <: Widget} <: CallOption{T}

American call option with underlying asset `T`. 
"""
struct AmericanCallOption{T<:Widget,S,D} <: CallOption{T}
    widget::T
    strike_price::S
    maturity::S
    risk_free_rate::S
    label::String
    values_library::Dict{String,Dict{String,D}}

    # kwargs constructor
    function AmericanCallOption{T,S,D}(;
        widget,
        strike_price = widget.prices[end],
        maturity = 1,
        risk_free_rate = 0.02,
        label = "",
        values_library = Dict{String,Dict{String,D}}(),
    ) where {T<:Widget,S,D}
        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity >= 0 ? nothing : error("maturity must be positive")
        values_library == Dict{String,Dict{String,D}}() ? nothing :
        @warn("It is not recommended to pass values through the constructor. \
        price!(Instrument, pricing_model) should be used")
        new{T,S,D}(widget, strike_price, maturity, risk_free_rate, label, values_library)
    end

    # ordered arguments constructor
    function AmericanCallOption{T,S,D}(
        widget,
        strike_price,
        maturity,
        risk_free_rate,
        label,
        values_library,
    ) where {T<:Widget,S,D}
        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity >= 0 ? nothing : error("maturity must be positive")
        values_library == Dict{String,Dict{String,D}}() ? nothing :
        @warn("It is not recommended to pass values through the constructor. \
        price!(Instrument, pricing_model) should be used")
        new{T,S,D}(widget, strike_price, maturity, risk_free_rate, label, values_library)
    end
end

# Outer constructors for passing only the widget
"""
    AmericanCallOption(widget, strike_price; kwargs...)
    AmericanCallOption(;kwargs...)
    AmericanCallOption{T<:Widget}(;kwargs...)
    AmericanCallOption{T<:Widget}(widget, strike_price, maturity, risk_free_rate, values_library)

Construct a AmericanCallOption with underlying asset `T`.

## Arguments
- `widget::Widget`: The underlying asset
- `strike_price`: Contracted price to buy underlying asset at maturity.
- `maturity`: time to maturity of the option with respect to implicit time period. Default 1.
- `risk_free_rate`: market risk free interest rate. Default is .02.
- `values_library`: The values returned from pricing models. Default initializes
to an empty dictionary. use `price!()` function to load theoretical option prices.

## Examples
```julia
stock = Stock([1,2,4,3,5,3]);

AmericanCallOption(stock, 10)

kwargs= Dict(:widget=>stock, :strike_price=>10, :maturity=>1, :risk_free_rate=>.02);
AmericanCallOption(;kwargs...)
```
"""
function AmericanCallOption(
    widget,
    strike_price = widget.prices[end],
    maturity = 1,
    risk_free_rate = 0.02,
    label = "",
    values_library = Dict{String,Dict{String,Float64}}(),
)    
    T = typeof(widget)
    strike_price, maturity, risk_free_rate = promote(strike_price, maturity, risk_free_rate)
    S = typeof(strike_price)
    D = valtype(valtype(values_library))

    return AmericanCallOption{T,S,D}(widget, strike_price, maturity, risk_free_rate, label, values_library)
end

function AmericanCallOption(;
    widget,
    strike_price = widget.prices[end],
    maturity = 1,
    risk_free_rate = 0.02,
    label = "",
    values_library = Dict{String,Dict{String,Float64}}(),
)
    T = typeof(widget)
    strike_price, maturity, risk_free_rate = promote(strike_price, maturity, risk_free_rate)
    S = typeof(strike_price)
    D = valtype(valtype(values_library))

    return AmericanCallOption{T,S,D}(widget, strike_price, maturity, risk_free_rate, label, values_library)
end

"""
    EuroPutOption{T <: Widget} <: CallOption{T}
European put option with underlying asset `T`. 
"""
struct EuroPutOption{T<:Widget,S,D} <: PutOption{T}
    widget::T
    strike_price::S
    maturity::S
    risk_free_rate::S
    label::String
    values_library::Dict{String,Dict{String,D}}

    # kwargs constructor
    function EuroPutOption{T,S,D}(;
        widget,
        strike_price = widget.prices[end],
        maturity = 1,
        risk_free_rate = 0.02,
        label = "",
        values_library = Dict{String,Dict{String,D}}(),
    ) where {T<:Widget,S,D}
        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity >= 0 ? nothing : error("maturity must be positive")
        values_library == Dict{String,Dict{String,D}}() ? nothing :
        @warn("It is not recommended to pass values through the constructor. \
        price!(Instrument, pricing_model) should be used")

        new{T,S,D}(widget, strike_price, maturity, risk_free_rate, label, values_library)
    end

    # ordered arguments constructor
    function EuroPutOption{T,S,D}(
        widget,
        strike_price,
        maturity,
        risk_free_rate,
        label,
        values_library,
    ) where {T<:Widget,S,D}
        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity >= 0 ? nothing : error("maturity must be positive")
        values_library == Dict{String,Dict{String,D}}() ? nothing :
        @warn("It is not recommended to pass values through the constructor. \
        price!(Instrument, pricing_model) should be used")

        new{T,S,D}(widget, strike_price, maturity, risk_free_rate, label, values_library)
    end
end

# Outer constructors
"""
    EuroPutOption(widget, strike_price; kwargs...)
    EuroPutOption(;kwargs...)
    EuroPutOption{T<:Widget}(;kwargs...)
    EuroPutOption{T<:Widget}(widget, strike_price, maturity, risk_free_rate, values_library)

Construct a EuroPutOption with underlying asset `T`. 

## Arguments
- `widget::Widget`: The underlying asset.
- `strike_price`: Contracted price to buy underlying asset at maturity.
- `maturity`: time to maturity of the option with respect to implicit time period. Default 1.
- `risk_free_rate`: market risk free interest rate. Default is .02.
- `values_library`: The values returned from pricing models. Default initializes
to an empty dictionary. use `price!()` function to load theoretical option prices.

## Examples
```julia
stock = Stock([1,2,4,3,5,3]);

EuroPutOption(stock, 10)

kwargs= Dict(:widget=>stock, :strike_price=>10, :maturity=>1, :risk_free_rate=>.02);
EuroPutOption(;kwargs...)
```
"""
function EuroPutOption(
    widget,
    strike_price = widget.prices[end],
    maturity = 1,
    risk_free_rate = 0.02,
    label = "",
    values_library = Dict{String,Dict{String,Float64}}(),
)
    T = typeof(widget)
    strike_price, maturity, risk_free_rate = promote(strike_price, maturity, risk_free_rate)
    S = typeof(strike_price)
    D = valtype(valtype(values_library))

    return EuroPutOption{T,S,D}(widget, strike_price,maturity,risk_free_rate,label,values_library)
end

function EuroPutOption(;
    widget,
    strike_price = widget.prices[end],
    maturity = 1,
    risk_free_rate = 0.02,
    label = "",
    values_library = Dict{String,Dict{String,Float64}}(),
)
    T = typeof(widget)
    strike_price, maturity, risk_free_rate = promote(strike_price, maturity, risk_free_rate)
    S = typeof(strike_price)
    D = valtype(valtype(values_library))

    return EuroPutOption{T,S,D}(widget, strike_price, maturity, risk_free_rate, label, values_library)
end

"""
    AmericanPutOption{T <: Widget} <: CallOption{T}

American put option with underlying asset `T`. 
"""
struct AmericanPutOption{T<:Widget,S,D} <: PutOption{T}
    widget::T
    strike_price::S
    maturity::S
    risk_free_rate::S
    label::String
    values_library::Dict{String,Dict{String,D}}

    # kwargs constructor
    function AmericanPutOption{T,S,D}(;
        widget,
        strike_price = widget.prices[end],
        maturity = 1,
        risk_free_rate = 0.02,
        label = "",
        values_library = Dict{String,Dict{String,D}}(),
    ) where {T<:Widget,S,D}

        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity >= 0 ? nothing : error("maturity must be positive")
        values_library == Dict{String,Dict{String,D}}() ? nothing :
        @warn("It is not recommended to pass values through the constructor. \
        price!(Instrument, pricing_model) should be used")
        new{T,S,D}(widget, strike_price, maturity, risk_free_rate, label, values_library)
    end

    # ordered arguments constructor
    function AmericanPutOption{T,S,D}(
        widget,
        strike_price,
        maturity,
        risk_free_rate,
        label,
        values_library,
    ) where {T<:Widget,S,D}

        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity >= 0 ? nothing : error("maturity must be positive")
        values_library == Dict{String,Dict{String,D}}() ? nothing :
        @warn("It is not recommended to pass values through the constructor. \
        price!(Instrument, pricing_model) should be used")

        new{T,S,D}(widget, strike_price, maturity, risk_free_rate, label, values_library)
    end
end

# Outer constructors for passing only the widget
"""
    AmericanPutOption(widget, strike_price; kwargs...)
    AmericanPutOption(;kwargs...)
    AmericanPutOption{T<:Widget}(;kwargs...)
    AmericanPutOption{T<:Widget}(widget, strike_price, maturity, risk_free_rate, values_library)

Construct an AmericanPutOption with underlying asset `T` 

## Arguments
- `widget::Widget`: underlying asset
- `strike_price`: Contracted price to buy underlying asset at maturity
- `maturity`: time to maturity of the option with respect to implicit time period. Default 1.
- `risk_free_rate`: market risk free interest rate. Default is .02.
- `values_library`: The values returned from pricing models. Default initializes
to an empty dictionary. use `price!()` function to load theoretical option prices

## Examples
```julia
stock = Stock([1,2,4,3,5,3]);

AmericanPutOption(stock, 10)

kwargs = Dict(:widget=>stock, :strike_price=>10, :maturity=>1, :risk_free_rate=>.02);
AmericanPutOption(;kwargs...)
```
"""
function AmericanPutOption(
    widget,
    strike_price = widget.prices[end],
    maturity = 1,
    risk_free_rate = 0.02,
    label = "",
    values_library = Dict{String,Dict{String,Float64}}(),
)    
    T = typeof(widget)
    strike_price, maturity, risk_free_rate = promote(strike_price, maturity, risk_free_rate)
    S = typeof(strike_price)
    D = valtype(valtype(values_library))

    return AmericanPutOption{T,S,D}(widget, strike_price,maturity,risk_free_rate,label,values_library)
end
    
function AmericanPutOption(;
    widget,
    strike_price = widget.prices[end],
    maturity = 1,
    risk_free_rate = 0.02,
    label = "",
    values_library = Dict{String,Dict{String,Float64}}(),
)
    T = typeof(widget)
    strike_price, maturity, risk_free_rate = promote(strike_price, maturity, risk_free_rate)
    S = typeof(strike_price)
    D = valtype(valtype(values_library))

    return AmericanPutOption{T,S,D}(widget, strike_price,maturity,risk_free_rate,label,values_library)
end

# ------ Type system for futures: subtype of FinancialInstrument ------
"""
    Future{T <: Widget} <: FinancialInstrument

Future contract with underlying asset 'T'.
"""
struct Future{T<:Widget,S,D} <: FinancialInstrument
    widget::T
    strike_price::S
    risk_free_rate::S
    maturity::S
    label::String
    values_library::Dict{String,Dict{String,D}}
end

# ------ Type system for stuff we haven't figured out yet ------ 
"""Still under development"""
struct ETF <: FinancialInstrument end
"""Still under development"""
struct InterestRateSwap <: FinancialInstrument end

#------- Helpers
function add_price_value(a_fin_inst::FinancialInstrument, a_new_price)
    a_new_price >= 0 ? nothing :
    @warn("You are trying to add a negative number to a prices list")
    push!(a_fin_inst.widget.prices, a_new_price)
end

function get_prices(a_fin_inst::FinancialInstrument)
    a_fin_inst.widget.prices
end
