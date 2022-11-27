# financial instruments that can be passed to simulate. They house underlying widgets as part
# of the insturment. Ex: Stock call options house an underlying stock
"""FinancialInstrument is the supertype for any instrument that uses a base asset
(widget) in its definition (like a financial derivative)"""
abstract type FinancialInstrument end

# ----- Type system for options: subtype of FinancialInstrument ------
"""
    Option <: FinancialInstrument

abstract FinancialInstrument subtype. Supertype of all options contract types
"""
abstract type Option <: FinancialInstrument end

# ----- Abstract type for all call and put options -----
"""
    CallOption{T <: Widget} <: Option

abstract Option subtype. Super type for all call options types
"""
abstract type CallOption{T<:Widget} <: Option end
"""
    PutOption{T <: Widget} <: Option

abstract Option subtype. Super type for all put options types
"""
abstract type PutOption{T<:Widget} <: Option end

# ----- Concrete types for Euro and American call options
"""
    EuroCallOption{T <: Widget} <: CallOption{T}

European call option with underlying asset `T`. 
"""
struct EuroCallOption{T<:Widget} <: CallOption{T}
    widget::T
    strike_price::AbstractFloat
    maturity::AbstractFloat
    risk_free_rate::AbstractFloat

    label::String
    values_library::Dict{String,Dict{String,AbstractFloat}}

    # kwargs constructor
    function EuroCallOption{T}(;
        widget,
        strike_price = widget.prices[end],
        maturity = 1,
        risk_free_rate = 0.02,
        label = "",
        values_library = Dict{String,Dict{String,AbstractFloat}}(),
    ) where {T<:Widget}
        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity >= 0 ? nothing : error("maturity must be positive ", maturity)
        values_library == Dict{String,Dict{String,AbstractFloat}}() ? nothing :
        @warn("It is not recommended to pass values through the constructor. \
        price!(Instrument, pricing_model) should be used")
        new{T}(widget, strike_price, maturity, risk_free_rate, label, values_library)
    end

    # ordered arguments constructor
    function EuroCallOption{T}(
        widget::T,
        strike_price,
        maturity,
        risk_free_rate,
        label,
        values_library,
    ) where {T<:Widget}
        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity >= 0 ? nothing : error("maturity must be positive")
        values_library == Dict{String,Dict{String,AbstractFloat}}() ? nothing :
        @warn("It is not recommended to pass values through the constructor. \
        price!(Instrument, pricing_model) should be used")

        new{T}(widget, strike_price, maturity, risk_free_rate, label, values_library)
    end
end

# Outer constructors for passing only the widget
"""
    EuroCallOption(widget, strike_price; kwargs...)
    EuroCallOption(;kwargs...)
    EuroCallOption{T<:Widget}(;kwargs...)
    EuroCallOption{T<:Widget}(widget, strike_price, maturity, risk_free_rate, values_library)

Construct a EuroCallOption with underlying asset `T` 

## Arguments
- `widget::Widget`: underlying asset
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
EuroCallOption(
    widget::Widget,
    strike_price::Real = widget.prices[end];
    maturity = 1,
    risk_free_rate = 0.02,
    label = "",
    values_library = Dict{String,Dict{String,AbstractFloat}}(),
) = EuroCallOption{typeof(widget)}(;
    widget = widget,
    strike_price = strike_price,
    maturity = maturity,
    risk_free_rate = risk_free_rate,
    label = label,
    values_library = values_library,
)

EuroCallOption(
    widget::Widget,
    strike_price::Real,
    maturity::Real,
    label::String,
    values_library::Dict{String,Dict{String,AbstractFloat}},
) = EuroCallOption{typeof(widget)}(;
    widget = widget,
    strik_price = strike_price,
    maturity = maturity,
    label = label,
    values_library = values_library,
)

EuroCallOption(;
    widget,
    strike_price = widget.prices[end],
    maturity = 1,
    risk_free_rate = 0.02,
    label = "",
    values_library = Dict{String,Dict{String,AbstractFloat}}(),
) = EuroCallOption{typeof(widget)}(;
    widget = widget,
    strike_price = strike_price,
    maturity = maturity,
    risk_free_rate = risk_free_rate,
    label = label,
    values_library = values_library,
)

"""
    AmericanCallOption{T <: Widget} <: CallOption{T}

American call option with underlying asset `T`. 
"""
struct AmericanCallOption{T<:Widget} <: CallOption{T}
    widget::T
    strike_price::AbstractFloat
    maturity::AbstractFloat
    risk_free_rate::AbstractFloat

    label::String
    values_library::Dict{String,Dict{String,AbstractFloat}}

    # kwargs constructor
    function AmericanCallOption{T}(;
        widget,
        strike_price = widget.prices[end],
        maturity = 1,
        risk_free_rate = 0.02,
        label = "",
        values_library = Dict{String,Dict{String,AbstractFloat}}(),
    ) where {T<:Widget}
        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity >= 0 ? nothing : error("maturity must be positive")
        values_library == Dict{String,Dict{String,AbstractFloat}}() ? nothing :
        @warn("It is not recommended to pass values through the constructor. \
        price!(Instrument, pricing_model) should be used")
        new{T}(widget, strike_price, maturity, risk_free_rate, label, values_library)
    end

    # ordered arguments constructor
    function AmericanCallOption{T}(
        widget::T,
        strike_price,
        maturity,
        risk_free_rate,
        label,
        values_library,
    ) where {T<:Widget}
        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity >= 0 ? nothing : error("maturity must be positive")
        values_library == Dict{String,Dict{String,AbstractFloat}}() ? nothing :
        @warn("It is not recommended to pass values through the constructor. \
        price!(Instrument, pricing_model) should be used")
        new{T}(widget, strike_price, maturity, risk_free_rate, label, values_library)
    end
end

# Outer constructors for passing only the widget
"""
    AmericanCallOption(widget, strike_price; kwargs...)
    AmericanCallOption(;kwargs...)
    AmericanCallOption{T<:Widget}(;kwargs...)
    AmericanCallOption{T<:Widget}(widget, strike_price, maturity, risk_free_rate, values_library)

Construct a AmericanCallOption with underlying asset `T` 

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

AmericanCallOption(stock, 10)

kwargs= Dict(:widget=>stock, :strike_price=>10, :maturity=>1, :risk_free_rate=>.02);
AmericanCallOption(;kwargs...)
```
"""
AmericanCallOption(
    widget::Widget,
    strike_price::Real = widget.prices[end];
    maturity = 1,
    risk_free_rate = 0.02,
    label = "",
    values_library = Dict{String,Dict{String,AbstractFloat}}(),
) = AmericanCallOption{typeof(widget)}(;
    widget = widget,
    strike_price = strike_price,
    maturity = maturity,
    risk_free_rate = risk_free_rate,
    label = label,
    values_library = values_library,
)

AmericanCallOption(
    widget::Widget,
    strike_price::Real,
    maturity::Real,
    risk_free_rate::Real,
    label::String,
    values_library::Dict{String,Dict{String,AbstractFloat}},
) = AmericanCallOption{typeof(widget)}(;
    widget = widget,
    strik_price = strike_price,
    maturity = maturity,
    risk_free_rate = risk_free_rate,
    label = label,
    values_library = values_library,
)

AmericanCallOption(;
    widget,
    strike_price = widget.prices[end],
    maturity = 1,
    risk_free_rate = 0.02,
    label = "",
    values_library = Dict{String,Dict{String,AbstractFloat}}(),
) = AmericanCallOption{typeof(widget)}(;
    widget = widget,
    strike_price = strike_price,
    maturity = maturity,
    risk_free_rate = risk_free_rate,
    label = label,
    values_library = values_library,
)

"""
    EuroPutOption{T <: Widget} <: CallOption{T}
European put option with underlying asset `T`. 
"""
struct EuroPutOption{T<:Widget} <: PutOption{T}
    widget::T
    strike_price::AbstractFloat
    maturity::AbstractFloat
    risk_free_rate::AbstractFloat

    label::String
    values_library::Dict{String,Dict{String,AbstractFloat}}

    # kwargs constructor
    function EuroPutOption{T}(;
        widget,
        strike_price = widget.prices[end],
        maturity = 1,
        risk_free_rate = 0.02,
        label = "",
        values_library = Dict{String,Dict{String,AbstractFloat}}(),
    ) where {T<:Widget}
        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity >= 0 ? nothing : error("maturity must be positive")
        values_library == Dict{String,Dict{String,AbstractFloat}}() ? nothing :
        @warn("It is not recommended to pass values through the constructor. \
        price!(Instrument, pricing_model) should be used")

        new{T}(widget, strike_price, maturity, risk_free_rate, label, values_library)
    end

    # ordered arguments constructor
    function EuroPutOption{T}(
        widget::T,
        strike_price,
        maturity,
        risk_free_rate,
        label,
        values_library,
    ) where {T<:Widget}
        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity >= 0 ? nothing : error("maturity must be positive")
        values_library == Dict{String,Dict{String,AbstractFloat}}() ? nothing :
        @warn("It is not recommended to pass values through the constructor. \
        price!(Instrument, pricing_model) should be used")

        new{T}(widget, strike_price, maturity, risk_free_rate, label, values_library)
    end
end

# Outer constructors for passing only the widget
"""
    EuroPutOption(widget, strike_price; kwargs...)
    EuroPutOption(;kwargs...)
    EuroPutOption{T<:Widget}(;kwargs...)
    EuroPutOption{T<:Widget}(widget, strike_price, maturity, risk_free_rate, values_library)

Construct a EuroPutOption with underlying asset `T` 

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

EuroPutOption(stock, 10)

kwargs= Dict(:widget=>stock, :strike_price=>10, :maturity=>1, :risk_free_rate=>.02);
EuroPutOption(;kwargs...)
```
"""
EuroPutOption(
    widget::Widget,
    strike_price::Real = widget.prices[end];
    maturity = 1,
    risk_free_rate = 0.02,
    label = "",
    values_library = Dict{String,Dict{String,AbstractFloat}}(),
) = EuroPutOption{typeof(widget)}(;
    widget = widget,
    strike_price = strike_price,
    maturity = maturity,
    risk_free_rate = risk_free_rate,
    label = label,
    values_library = values_library,
)

EuroPutOption(
    widget::Widget,
    strike_price::Real,
    maturity::Real,
    risk_free_rate::Real,
    label::String,
    values_library::Dict{String,Dict{String,AbstractFloat}},
) = EuroPutOption{typeof(widget)}(;
    widget = widget,
    strik_price = strike_price,
    maturity = maturity,
    risk_free_rate = risk_free_rate,
    label,
    values_library = values_library,
)

EuroPutOption(;
    widget,
    strike_price = widget.prices[end],
    maturity = 1,
    risk_free_rate = 0.02,
    label = "",
    values_library = Dict{String,Dict{String,AbstractFloat}}(),
) = EuroPutOption{typeof(widget)}(;
    widget = widget,
    strike_price = strike_price,
    maturity = maturity,
    risk_free_rate = risk_free_rate,
    label = label,
    values_library = values_library,
)

"""
    AmericanPutOption{T <: Widget} <: CallOption{T}

American put option with underlying asset `T`. 
"""
struct AmericanPutOption{T<:Widget} <: PutOption{T}
    widget::T
    strike_price::AbstractFloat
    maturity::AbstractFloat
    risk_free_rate::AbstractFloat

    label::String
    values_library::Dict{String,Dict{String,AbstractFloat}}

    # kwargs constructor
    function AmericanPutOption{T}(;
        widget,
        strike_price = widget.prices[end],
        maturity = 1,
        risk_free_rate = 0.02,
        label = "",
        values_library = Dict{String,Dict{String,AbstractFloat}}(),
    ) where {T<:Widget}

        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity >= 0 ? nothing : error("maturity must be positive")
        values_library == Dict{String,Dict{String,AbstractFloat}}() ? nothing :
        @warn("It is not recommended to pass values through the constructor. \
        price!(Instrument, pricing_model) should be used")

        new{T}(widget, strike_price, maturity, risk_free_rate, label, values_library)
    end

    # ordered arguments constructor
    function AmericanPutOption{T}(
        widget::T,
        strike_price,
        maturity,
        risk_free_rate,
        label,
        values_library,
    ) where {T<:Widget}

        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity >= 0 ? nothing : error("maturity must be positive")
        values_library == Dict{String,Dict{String,AbstractFloat}}() ? nothing :
        @warn("It is not recommended to pass values through the constructor. \
        price!(Instrument, pricing_model) should be used")

        new{T}(widget, strike_price, maturity, risk_free_rate, label, values_library)
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
AmericanPutOption(
    widget::Widget,
    strike_price::Real = widget.prices[end];
    maturity = 1,
    risk_free_rate = 0.02,
    label = "",
    values_library = Dict{String,Dict{String,AbstractFloat}}(),
) = AmericanPutOption{typeof(widget)}(;
    widget = widget,
    strike_price = strike_price,
    maturity = maturity,
    risk_free_rate = risk_free_rate,
    label = label,
    values_library = values_library,
)

AmericanPutOption(
    widget::Widget,
    strike_price::Real,
    maturity::Real,
    risk_free_rate::Real,
    values_library::Dict{String,Dict{String,AbstractFloat}},
) = AmericanPutOption{typeof(widget)}(;
    widget = widget,
    strik_price = strike_price,
    maturity = maturity,
    risk_free_rate = risk_free_rate,
    label = label,
    values_library = values_library,
)

AmericanPutOption(;
    widget,
    strike_price = widget.prices[end],
    maturity = 1,
    risk_free_rate = 0.02,
    label = "",
    values_library = Dict{String,Dict{String,AbstractFloat}}(),
) = AmericanPutOption{typeof(widget)}(;
    widget = widget,
    strike_price = strike_price,
    maturity = maturity,
    risk_free_rate = risk_free_rate,
    label = label,
    values_library = values_library,
)



# ------ Type system for futures: subtype of FinancialInstrument ------
"""
    Future{T <: Widget} <: FinancialInstrument

Future contract with underlying asset T.
"""
struct Future{T<:Widget} <: FinancialInstrument
    widget::T
    strike_price::AbstractFloat
    risk_free_rate::AbstractFloat
    maturity::AbstractFloat
    label::String
    values_library::Dict{String,Dict{String,AbstractFloat}}
end

# ------ Type system for stuff we haven't figured out yet ------ 
"""Still under development"""
struct ETF <: FinancialInstrument end
"""Still under development"""
struct InterestRateSwap <: FinancialInstrument end

#------- Helpers
function add_price_value(a_fin_inst::FinancialInstrument, a_new_price::Real)
    a_new_price >= 0 ? nothing :
    @warn("You are trying to add a negative number to a prices list")
    push!(a_fin_inst.widget.prices, a_new_price)
end

function get_prices(a_fin_inst::FinancialInstrument)
    a_fin_inst.widget.prices
end
