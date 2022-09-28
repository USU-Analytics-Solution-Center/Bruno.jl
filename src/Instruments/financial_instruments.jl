# financial instruments that can be passed to simulate. They house underlying widgets as part
# of the insturment. Ex: Stock call options house an underlying stock

abstract type FinancialInstrument end

# ----- Type system for options: subtype of FinancialInstrument ------
abstract type Option <: FinancialInstrument end

# ----- Abstract type for all call and put options -----
abstract type CallOption{T <:Widget} <: Option end
abstract type PutOption{T <:Widget} <: Option end

# ----- Concrete types for Euro and American call options
"""
    EuroCallOption{T <: Widget} <: CallOption{T}

European call option with underlying asset `T`. 
"""
struct EuroCallOption{T <: Widget} <: CallOption{T}
    widget::T
    strike_price::AbstractFloat
    maturity::AbstractFloat
    risk_free_rate::AbstractFloat
    value::Dict{String, AbstractFloat}
    
    # kwargs constructor
    function EuroCallOption{T}(; widget, strike_price, maturity = 1, risk_free_rate = .02,
        value = Dict{String, AbstractFloat}()) where {T <: Widget}
        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity > 0 ? nothing : error("maturity must be positive")
        value == Dict{String, AbstractFloat}() ? nothing : 
            @warn("It is not recommended to pass values through the constructor, instead 
            model!(Instrument) should be used")
        new{T}(widget, strike_price,  maturity, risk_free_rate, value)
    end

    # ordered arguments constructor
    function EuroCallOption{T}(widget::T, strike_price, maturity, risk_free_rate, value) where {T <: Widget}
        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity > 0 ? nothing : error("maturity must be positive")
        value == Dict{String, AbstractFloat}() ? nothing : 
            @warn("It is not recommended to pass values through the constructor, instead 
            model!(Instrument) should be used")
        new{T}(widget, strike_price,  maturity, risk_free_rate, value)
    end
end

# Outer constructors for passing only the widget
"""
    EuroCallOption(widget, strike_price; kwargs...)
    EuroCallOption(;kwargs...)
    EuroCallOption{T<:Widget}(;kwargs...)
    EuroCallOption{T<:Widget}(widget, strike_price, maturity, risk_free_rate, value)

Construct a EuroCallOption with underlying asset `T` 

## Arguments
- `widget::Widget`: underlying asset
- `strike_price`: Contracted price to buy underlying asset at maturity
- `maturity`: time to maturity of the option in years. Default 1.
- `risk_free_rate`: market risk free interest rate. Default is .02.
- `value`: The value or price of the call option using different models. Default initializes
to an empty dictionary. use `price!()` function to load theoretical option prices

## Examples
```jldoctest
julia> stock = Stock([1,2,4,3,5,3])

julia> EuroCallOption(stock, 10)
EuroCallOption{Stock}(Stock(AbstractFloat[1.0, 2.0, 4.0, 3.0, 5.0, 3.0], "", 0.5753613747628236), 10.0, 1.0, 0.02, Dict{String, AbstractFloat}())

julia> EuroCallOption(;widget=stock, strike_price=10, maturity=1, risk_free_rate=.02)
EuroCallOption{Stock}(Stock(AbstractFloat[1.0, 2.0, 4.0, 3.0, 5.0, 3.0], "", 0.5753613747628236), 10.0, 1.0, 0.02, Dict{String, AbstractFloat}())
```
"""
EuroCallOption(widget::Widget, strike_price::Real; maturity = 1, risk_free_rate = .02, value = Dict{String, AbstractFloat}()) = 
    EuroCallOption{typeof(widget)}(;widget = widget, strike_price = strike_price, maturity = maturity, risk_free_rate = risk_free_rate, value = value)
EuroCallOption(widget::Widget, strike_price:: Real, maturity::Real, value::Dict{String, AbstractFloat}) =
    EuroCallOption{typeof(widget)}(;widget = widget, strik_price = strike_price, maturity = maturity, value = value)
EuroCallOption(;widget, strike_price, maturity = 1, value = Dict{String, AbstractFloat}()) = 
    EuroCallOption{typeof(widget)}(;widget = widget, strike_price = strike_price, maturity = maturity, value = value)

"""
    AmericanCallOption{T <: Widget} <: CallOption{T}

American call option with underlying asset `T`. 
"""
struct AmericanCallOption{T <: Widget} <: CallOption{T}
    widget::T
    strike_price::AbstractFloat
    maturity::AbstractFloat
    risk_free_rate::AbstractFloat
    value::Dict{String, AbstractFloat}
    
    # kwargs constructor
    function AmericanCallOption{T}(; widget, strike_price, maturity = 1, risk_free_rate = .02,
        value = Dict{String, AbstractFloat}()) where {T <: Widget}
        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity > 0 ? nothing : error("maturity must be positive")
        value == Dict{String, AbstractFloat}() ? nothing : 
            @warn("It is not recommended to pass values through the constructor, instead 
            model!(Instrument) should be used")
        new{T}(widget, strike_price,  maturity, risk_free_rate, value)
    end

    # ordered arguments constructor
    function AmericanCallOption{T}(widget::T, strike_price, maturity, risk_free_rate, value) where {T <: Widget}
        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity > 0 ? nothing : error("maturity must be positive")
        value == Dict{String, AbstractFloat}() ? nothing : 
            @warn("It is not recommended to pass values through the constructor, instead 
            model!(Instrument) should be used")
        new{T}(widget, strike_price,  maturity, risk_free_rate, value)
    end
end

# Outer constructors for passing only the widget
"""
    AmericanCallOption(widget, strike_price; kwargs...)
    AmericanCallOption(;kwargs...)
    AmericanCallOption{T<:Widget}(;kwargs...)
    AmericanCallOption{T<:Widget}(widget, strike_price, maturity, risk_free_rate, value)

Construct a AmericanCallOption with underlying asset `T` 

## Arguments
- `widget::Widget`: underlying asset
- `strike_price`: Contracted price to buy underlying asset at maturity
- `maturity`: time to maturity of the option in years. Default 1.
- `risk_free_rate`: market risk free interest rate. Default is .02.
- `value`: The value or price of the call option using different models. Default initializes
to an empty dictionary. use `price!()` function to load theoretical option prices

## Examples
```jldoctest
julia> stock = Stock([1,2,4,3,5,3])

julia> AmericanCallOption(stock, 10)
AmericanCallOption{Stock}(Stock(AbstractFloat[1.0, 2.0, 4.0, 3.0, 5.0, 3.0], "", 0.5753613747628236), 10.0, 1.0, 0.02, Dict{String, AbstractFloat}())

julia> AmericanCallOption(;widget=stock, strike_price=10, maturity=1, risk_free_rate=.02)
AmericanCallOption{Stock}(Stock(AbstractFloat[1.0, 2.0, 4.0, 3.0, 5.0, 3.0], "", 0.5753613747628236), 10.0, 1.0, 0.02, Dict{String, AbstractFloat}())
```
"""
AmericanCallOption(widget::Widget, strike_price::Real; maturity = 1, risk_free_rate = .02, value = Dict{String, AbstractFloat}()) = 
    AmericanCallOption{typeof(widget)}(;widget = widget, strike_price = strike_price, maturity = maturity, risk_free_rate = risk_free_rate, value = value)
AmericanCallOption(widget::Widget, strike_price:: Real, maturity::Real, value::Dict{String, AbstractFloat}) =
    AmericanCallOption{typeof(widget)}(;widget = widget, strik_price = strike_price, maturity = maturity, value = value)
AmericanCallOption(;widget, strike_price, maturity = 1, value = Dict{String, AbstractFloat}()) = 
    AmericanCallOption{typeof(widget)}(;widget = widget, strike_price = strike_price, maturity = maturity, value = value)

"""
    EuroPutOption{T <: Widget} <: CallOption{T}

European put option with underlying asset `T`. 
"""
struct EuroPutOption{T <: Widget} <: PutOption{T}
    widget::T
    strike_price::AbstractFloat
    maturity::AbstractFloat
    risk_free_rate::AbstractFloat
    value::Dict{String, AbstractFloat}
    
    # kwargs constructor
    function EuroPutOption{T}(; widget, strike_price, maturity = 1, risk_free_rate = .02,
        value = Dict{String, AbstractFloat}()) where {T <: Widget}
        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity > 0 ? nothing : error("maturity must be positive")
        value == Dict{String, AbstractFloat}() ? nothing : 
            @warn("It is not recommended to pass values through the constructor, instead 
            model!(Instrument) should be used")
        new{T}(widget, strike_price,  maturity, risk_free_rate, value)
    end

    # ordered arguments constructor
    function EuroPutOption{T}(widget::T, strike_price, maturity, risk_free_rate, value) where {T <: Widget}
        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity > 0 ? nothing : error("maturity must be positive")
        value == Dict{String, AbstractFloat}() ? nothing : 
            @warn("It is not recommended to pass values through the constructor, instead 
            model!(Instrument) should be used")
        new{T}(widget, strike_price,  maturity, risk_free_rate, value)
    end
end

# Outer constructors for passing only the widget
"""
    EuroPutOption(widget, strike_price; kwargs...)
    EuroPutOption(;kwargs...)
    EuroPutOption{T<:Widget}(;kwargs...)
    EuroPutOption{T<:Widget}(widget, strike_price, maturity, risk_free_rate, value)

Construct a EuroPutOption with underlying asset `T` 

## Arguments
- `widget::Widget`: underlying asset
- `strike_price`: Contracted price to buy underlying asset at maturity
- `maturity`: time to maturity of the option in years. Default 1.
- `risk_free_rate`: market risk free interest rate. Default is .02.
- `value`: The value or price of the call option using different models. Default initializes
to an empty dictionary. use `price!()` function to load theoretical option prices

## Examples
```jldoctest
julia> stock = Stock([1,2,4,3,5,3])

julia> EuroPutOption(stock, 10)
EuroPutOption{Stock}(Stock(AbstractFloat[1.0, 2.0, 4.0, 3.0, 5.0, 3.0], "", 0.5753613747628236), 10.0, 1.0, 0.02, Dict{String, AbstractFloat}())

julia> EuroPutOption(;widget=stock, strike_price=10, maturity=1, risk_free_rate=.02)
EuroPutOption{Stock}(Stock(AbstractFloat[1.0, 2.0, 4.0, 3.0, 5.0, 3.0], "", 0.5753613747628236), 10.0, 1.0, 0.02, Dict{String, AbstractFloat}())
```
"""
EuroPutOption(widget::Widget, strike_price::Real; maturity = 1, risk_free_rate = .02, value = Dict{String, AbstractFloat}()) = 
    EuroPutOption{typeof(widget)}(;widget = widget, strike_price = strike_price, maturity = maturity, risk_free_rate = risk_free_rate, value = value)
EuroPutOption(widget::Widget, strike_price:: Real, maturity::Real, value::Dict{String, AbstractFloat}) =
    EuroPutOption{typeof(widget)}(;widget = widget, strik_price = strike_price, maturity = maturity, value = value)
EuroPutOption(;widget, strike_price, maturity = 1, value = Dict{String, AbstractFloat}()) = 
    EuroPutOption{typeof(widget)}(;widget = widget, strike_price = strike_price, maturity = maturity, value = value)

"""
    AmericanPutOption{T <: Widget} <: CallOption{T}

American put option with underlying asset `T`. 
"""
struct AmericanPutOption{T <: Widget} <: PutOption{T}
    widget::T
    strike_price::AbstractFloat
    maturity::AbstractFloat
    risk_free_rate::AbstractFloat
    value::Dict{String, AbstractFloat}
    
    # kwargs constructor
    function AmericanPutOption{T}(; widget, strike_price, maturity = 1, risk_free_rate = .02,
        value = Dict{String, AbstractFloat}()) where {T <: Widget}
        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity > 0 ? nothing : error("maturity must be positive")
        value == Dict{String, AbstractFloat}() ? nothing : 
            @warn("It is not recommended to pass values through the constructor, instead 
            model!(Instrument) should be used")
        new{T}(widget, strike_price,  maturity, risk_free_rate, value)
    end

    # ordered arguments constructor
    function AmericanPutOption{T}(widget::T, strike_price, maturity, risk_free_rate, value) where {T <: Widget}
        strike_price >= 0 ? nothing : error("strike_price must be non-negative")
        maturity > 0 ? nothing : error("maturity must be positive")
        value == Dict{String, AbstractFloat}() ? nothing : 
            @warn("It is not recommended to pass values through the constructor, instead 
            model!(Instrument) should be used")
        new{T}(widget, strike_price,  maturity, risk_free_rate, value)
    end
end

# Outer constructors for passing only the widget
"""
    AmericanPutOption(widget, strike_price; kwargs...)
    AmericanPutOption(;kwargs...)
    AmericanPutOption{T<:Widget}(;kwargs...)
    AmericanPutOption{T<:Widget}(widget, strike_price, maturity, risk_free_rate, value)

Construct an AmericanPutOption with underlying asset `T` 

## Arguments
- `widget::Widget`: underlying asset
- `strike_price`: Contracted price to buy underlying asset at maturity
- `maturity`: time to maturity of the option in years. Default 1.
- `risk_free_rate`: market risk free interest rate. Default is .02.
- `value`: The value or price of the call option using different models. Default initializes
to an empty dictionary. use `price!()` function to load theoretical option prices

## Examples
```jldoctest
julia> stock = Stock([1,2,4,3,5,3])

julia> AmericanPutOption(stock, 10)
AmericanPutOption{Stock}(Stock(AbstractFloat[1.0, 2.0, 4.0, 3.0, 5.0, 3.0], "", 0.5753613747628236), 10.0, 1.0, 0.02, Dict{String, AbstractFloat}())

julia> AmericanPutOption(;widget=stock, strike_price=10, maturity=1, risk_free_rate=.02)
AmericanPutOption{Stock}(Stock(AbstractFloat[1.0, 2.0, 4.0, 3.0, 5.0, 3.0], "", 0.5753613747628236), 10.0, 1.0, 0.02, Dict{String, AbstractFloat}())
```
"""
AmericanPutOption(widget::Widget, strike_price::Real; maturity = 1, risk_free_rate = .02, value = Dict{String, AbstractFloat}()) = 
    AmericanPutOption{typeof(widget)}(;widget = widget, strike_price = strike_price, maturity = maturity, risk_free_rate = risk_free_rate, value = value)
AmericanPutOption(widget::Widget, strike_price:: Real, maturity::Real, value::Dict{String, AbstractFloat}) =
    AmericanPutOption{typeof(widget)}(;widget = widget, strik_price = strike_price, maturity = maturity, value = value)
AmericanPutOption(;widget, strike_price, maturity = 1, value = Dict{String, AbstractFloat}()) = 
    AmericanPutOption{typeof(widget)}(;widget = widget, strike_price = strike_price, maturity = maturity, value = value)


# ------ Type system for futures: subtype of FinancialInstrument ------
"""Still under development"""
struct Future{T <: Widget} <: FinancialInstrument 
    widget::T
    strike_price::AbstractFloat
    risk_free_rate::AbstractFloat
    maturity::AbstractFloat
    value::Dict{String, AbstractFloat}
end

# ------ Type system for stuff we haven't figured out yet ------ 
"""Still under development"""
struct ETF <: FinancialInstrument end
"""Still under development"""
struct InterestRateSwap <: FinancialInstrument end

