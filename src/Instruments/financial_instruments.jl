# financial instruments that can be passed to simulate. They house underlying widgets as part
# of the insturment. Ex: Stock call options house an underlying stock

abstract type FinancialInstrument end

# ----- Type system for options: subtype of FinancialInstrument ------
abstract type Option <: FinancialInstrument end

# ----- Abstract type for all call and put options -----
abstract type CallOption{T <:Widget} <: Option end
abstract type PutOption{T <:Widget} <: Option end

# ----- Concrete types for Euro and American call options
struct EuroCallOption{T <: Widget} <: CallOption{T}
    widget::T
    strike_price::AbstractFloat
    maturity::AbstractFloat
    risk_free_rate::AbstractFloat
    value::Dict{String, AbstractFloat}
    
    # kwargs constructor
    function EuroCallOption{T}(; widget, strike_price, maturity = 1, risk_free_rate = .02,
        value = Dict{String, AbstractFloat}()) where {T <: Widget}
        value == Dict{String, AbstractFloat}() ? nothing : 
            @warn("It is not recommended to pass values through the constructor, instead 
            model!(Instrument) should be used")
        new{T}(widget, strike_price,  maturity, risk_free_rate, value)
    end

    # ordered arguments constructor
    function EuroCallOption{T}(widget::T, strike_price, maturity, risk_free_rate, value) where {T <: Widget}
        new{T}(widget, strike_price,  maturity, risk_free_rate, value)
    end
end

# Outer constructors for passing only the widget
EuroCallOption(widget::Widget, strike_price::Real; maturity = 1, risk_free_rate = .02, value = Dict{String, AbstractFloat}()) = 
    EuroCallOption{typeof(widget)}(;widget = widget, strike_price = strike_price, maturity = maturity, risk_free_rate = risk_free_rate, value = value)
EuroCallOption(widget::Widget, strike_price:: Real, maturity::Real, value::Dict{String, AbstractFloat}) =
    EuroCallOption{typeof(widget)}(;widget = widget, strik_price = strike_price, maturity = maturity, value = value)
EuroCallOption(;widget, strike_price, maturity = 1, value = Dict{String, AbstractFloat}()) = 
    EuroCallOption{typeof(widget)}(;widget = widget, strike_price = strike_price, maturity = maturity, value = value)

struct AmericanCallOption{T <: Widget} <: CallOption{T}
    widget::T
    strike_price::AbstractFloat
    maturity::AbstractFloat
    risk_free_rate::AbstractFloat
    value::Dict{String, AbstractFloat}
    
    # kwargs constructor
    function AmericanCallOption{T}(; widget, strike_price, maturity = 1, risk_free_rate = .02,
        value = Dict{String, AbstractFloat}()) where {T <: Widget}
        value == Dict{String, AbstractFloat}() ? nothing : 
            @warn("It is not recommended to pass values through the constructor, instead 
            model!(Instrument) should be used")
        new{T}(widget, strike_price,  maturity, risk_free_rate, value)
    end

    # ordered arguments constructor
    function AmericanCallOption{T}(widget::T, strike_price, maturity, risk_free_rate, value) where {T <: Widget}
        new{T}(widget, strike_price,  maturity, risk_free_rate, value)
    end
end

# Outer constructors for passing only the widget
AmericanCallOption(widget::Widget, strike_price::Real; maturity = 1, risk_free_rate = .02, value = Dict{String, AbstractFloat}()) = 
    AmericanCallOption{typeof(widget)}(;widget = widget, strike_price = strike_price, maturity = maturity, risk_free_rate = risk_free_rate, value = value)
AmericanCallOption(widget::Widget, strike_price:: Real, maturity::Real, value::Dict{String, AbstractFloat}) =
    AmericanCallOption{typeof(widget)}(;widget = widget, strik_price = strike_price, maturity = maturity, value = value)
AmericanCallOption(;widget, strike_price, maturity = 1, value = Dict{String, AbstractFloat}()) = 
    AmericanCallOption{typeof(widget)}(;widget = widget, strike_price = strike_price, maturity = maturity, value = value)

struct EuroPutOption{T <: Widget} <: PutOption{T}
    widget::T
    strike_price::AbstractFloat
    maturity::AbstractFloat
    risk_free_rate::AbstractFloat
    value::Dict{String, AbstractFloat}
    
    # kwargs constructor
    function EuroPutOption{T}(; widget, strike_price, maturity = 1, risk_free_rate = .02,
        value = Dict{String, AbstractFloat}()) where {T <: Widget}
        value == Dict{String, AbstractFloat}() ? nothing : 
            @warn("It is not recommended to pass values through the constructor, instead 
            model!(Instrument) should be used")
        new{T}(widget, strike_price,  maturity, risk_free_rate, value)
    end

    # ordered arguments constructor
    function EuroPutOption{T}(widget::T, strike_price, maturity, risk_free_rate, value) where {T <: Widget}
        new{T}(widget, strike_price,  maturity, risk_free_rate, value)
    end
end

# Outer constructors for passing only the widget
EuroPutOption(widget::Widget, strike_price::Real; maturity = 1, risk_free_rate = .02, value = Dict{String, AbstractFloat}()) = 
    EuroPutOption{typeof(widget)}(;widget = widget, strike_price = strike_price, maturity = maturity, risk_free_rate = risk_free_rate, value = value)
EuroPutOption(widget::Widget, strike_price:: Real, maturity::Real, value::Dict{String, AbstractFloat}) =
    EuroPutOption{typeof(widget)}(;widget = widget, strik_price = strike_price, maturity = maturity, value = value)
EuroPutOption(;widget, strike_price, maturity = 1, value = Dict{String, AbstractFloat}()) = 
    EuroPutOption{typeof(widget)}(;widget = widget, strike_price = strike_price, maturity = maturity, value = value)

struct AmericanPutOption{T <: Widget} <: PutOption{T}
    widget::T
    strike_price::AbstractFloat
    maturity::AbstractFloat
    risk_free_rate::AbstractFloat
    value::Dict{String, AbstractFloat}
    
    # kwargs constructor
    function AmericanPutOption{T}(; widget, strike_price, maturity = 1, risk_free_rate = .02,
        value = Dict{String, AbstractFloat}()) where {T <: Widget}
        value == Dict{String, AbstractFloat}() ? nothing : 
            @warn("It is not recommended to pass values through the constructor, instead 
            model!(Instrument) should be used")
        new{T}(widget, strike_price,  maturity, risk_free_rate, value)
    end

    # ordered arguments constructor
    function AmericanPutOption{T}(widget::T, strike_price, maturity, risk_free_rate, value) where {T <: Widget}
        new{T}(widget, strike_price,  maturity, risk_free_rate, value)
    end
end

# Outer constructors for passing only the widget
AmericanPutOption(widget::Widget, strike_price::Real; maturity = 1, risk_free_rate = .02, value = Dict{String, AbstractFloat}()) = 
    AmericanPutOption{typeof(widget)}(;widget = widget, strike_price = strike_price, maturity = maturity, risk_free_rate = risk_free_rate, value = value)
AmericanPutOption(widget::Widget, strike_price:: Real, maturity::Real, value::Dict{String, AbstractFloat}) =
    AmericanPutOption{typeof(widget)}(;widget = widget, strik_price = strike_price, maturity = maturity, value = value)
AmericanPutOption(;widget, strike_price, maturity = 1, value = Dict{String, AbstractFloat}()) = 
    AmericanPutOption{typeof(widget)}(;widget = widget, strike_price = strike_price, maturity = maturity, value = value)


# ------ Type system for futures: subtype of FinancialInstrument ------
struct Future{T <: Widget} <: FinancialInstrument 
    widget::T
    strike_price::AbstractFloat
    risk_free_rate::AbstractFloat
    maturity::AbstractFloat
    value::Dict{String, AbstractFloat}
end

# ------ Type system for stuff we haven't figured out yet ------ 
struct ETF <: FinancialInstrument end
struct InterestRateSwap <: FinancialInstrument end

