# financial instruments that can be passed to simulate. They house underlying widgets as part
# of the insturment. Ex: Stock call options house an underlying stock

abstract type FinancialInstrument end

# ----- Type system for options: subtype of FinancialInstrument ------
abstract type Option <: FinancialInstrument end
abstract type CallOption <: Option end
abstract type PutOption <: Option end

struct EuroCallOption{T <: Widget} <: CallOption
    widget::T
    maturity::AbstractFloat
    value::Dict{String, AbstractFloat}
    
    # kwargs constructor
    function EuroCallOption{T}(; widget, maturity = 1,
        value = Dict{String, AbstractFloat}()) where {T <: Widget}
        value == Dict{String, AbstractFloat}() ? nothing : 
            @warn("It is not recommended to pass values through the constructor, instead 
            model!(Instrument) should be used")
        new{T}(widget, maturity, value)
    end

    # ordered arguments constructor
    function EuroCallOption{T}(widget::T, maturity, value) where {T <: Widget}
        new{T}(widget, maturity, value)
    end
end

# Outer constructors for passing only the widget
EuroCallOption(widget::Widget) = EuroCallOption{typeof(widget)}(;widget = widget)
EuroCallOption(widget::Widget, maturity::Real, value::Dict{String, AbstractFloat}) =
    EuroCallOption{typeof(widget)}(;widget = widget, maturity = maturity, value = value)
EuroCallOption(;widget, maturity = 1, value = Dict{String, AbstractFloat}()) = 
    EuroCallOption{typeof(widget)}(;widget = widget, maturity = maturity, value = value)


struct AmericanCallOption{T <: Widget} <: CallOption 
    widget::T
    maturity::AbstractFloat
    value::Dict{String, AbstractFloat}

    # kwargs constructor
    function AmericanCallOption{T}(; widget, maturity = 1,
        value = Dict{String, AbstractFloat}()) where {T <: Widget}
        value == Dict{String, AbstractFloat}() ? nothing : 
            @warn("It is not recommended to pass values through the constructor, instead 
            model!(Instrument) should be used")
        new{T}(widget, maturity, value)
    end

    # ordered arguments constructor
    function AmericanCallOption{T}(widget::T, maturity, value) where {T <: Widget}
        new{T}(widget, maturity, value)
    end
end

# Outer constructors for passing only the widget
AmericanCallOption(widget::Widget) = AmericanCallOption{typeof(widget)}(;widget = widget)
AmericanCallOption(widget::Widget, maturity::Real, value::Dict{String, AbstractFloat}) =
    AmericanCallOption{typeof(widget)}(;widget = widget, maturity = maturity, value = value)
AmericanCallOption(;widget, maturity = 1, value = Dict{String, AbstractFloat}()) = 
    AmericanCallOption{typeof(widget)}(;widget = widget, maturity = maturity, value = value)

struct EuroPutOption{T <: Widget} <: PutOption
    widget::T
    maturity::AbstractFloat
    value::Dict{String, AbstractFloat}

    # kwargs constructor
    function EuroPutOption{T}(; widget, maturity = 1,
        value = Dict{String, AbstractFloat}()) where {T <: Widget}
        value == Dict{String, AbstractFloat}() ? nothing : 
            @warn("It is not recommended to pass values through the constructor, instead 
            model!(Instrument) should be used")
        new{T}(widget, maturity, value)
    end

    # ordered arguments constructor
    function EuroPutOption{T}(widget::T, maturity, value) where {T <: Widget}
        new{T}(widget, maturity, value)
    end
end

# Outer constructors for passing only the widget
EuroPutOption(widget::Widget) = EuroPutOption{typeof(widget)}(;widget = widget)
EuroPutOption(widget::Widget, maturity::Real, value::Dict{String, AbstractFloat}) =
    EuroPutOption{typeof(widget)}(;widget = widget, maturity = maturity, value = value)
EuroPutOption(;widget, maturity = 1, value = Dict{String, AbstractFloat}()) = 
    EuroPutOption{typeof(widget)}(;widget = widget, maturity = maturity, value = value)

struct AmericanPutOption{T <: Widget} <: PutOption
    widget::T
    maturity::AbstractFloat
    value::Dict{String, AbstractFloat}

    # kwargs constructor
    function AmericanPutOption{T}(; widget, maturity = 1,
        value = Dict{String, AbstractFloat}()) where {T <: Widget}
        value == Dict{String, AbstractFloat}() ? nothing : 
            @warn("It is not recommended to pass values through the constructor, instead 
            model!(Instrument) should be used")
        new{T}(widget, maturity, value)
    end

    # ordered arguments constructor
    function AmericanPutOption{T}(widget::T, maturity, value) where {T <: Widget}
        new{T}(widget, maturity, value)
    end
end

# Outer constructors for passing only the widget
AmericanPutOption(widget::Widget) = AmericanPutOption{typeof(widget)}(;widget = widget)
AmericanPutOption(widget::Widget, maturity::Real, value::Dict{String, AbstractFloat}) =
    AmericanPutOption{typeof(widget)}(;widget = widget, maturity = maturity, value = value)
AmericanPutOption(;widget, maturity = 1, value = Dict{String, AbstractFloat}()) = 
    AmericanPutOption{typeof(widget)}(;widget = widget, maturity = maturity, value = value)


# ------ Type system for futures: subtype of FinancialInstrument ------
struct Future{T <: Widget} <: FinancialInstrument 
    widget::T
    maturity::AbstractFloat
    value::Dict{String, AbstractFloat}
end

# ------ Type system for stuff we haven't figured out yet ------ 
struct ETF <: FinancialInstrument end
struct InterestRateSwap <: FinancialInstrument end

