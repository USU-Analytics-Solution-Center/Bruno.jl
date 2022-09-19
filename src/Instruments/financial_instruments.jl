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
    function EuroCallOption(; widget, maturity = 1, value = Dict{String, AbstractFloat}())  
        value == Dict{String, AbstractFloat}() ? nothing : 
            @warn("It is not recommended to pass values through the constructor, instead 
            model!(Instrument) should be used")
        new{typeof(widget)}(widget, maturity, value)
    end
end

# Outer constructors for passing only the widget
EuroCallOption(widget::Widget) = EuroCallOption(;widget = widget)
EuroCallOption(widget::Widget, maturity::Real, value::Dict{String, AbstractFloat}) =
    EuroCallOption(;widget = widget, maturity = maturity, value = value)

struct AmericanCallOption{T <: Widget} <: CallOption 
    widget::T
    maturity::AbstractFloat
    value::Dict{String, AbstractFloat}

    # kwargs constructor
    function AmericanCallOption(; widget, maturity = 1, value = Dict{String, AbstractFloat}())  
        value == Dict{String, AbstractFloat}() ? nothing : 
            @warn("It is not recommended to pass values through the constructor, instead 
            model!(Instrument) should be used")
        new{typeof(widget)}(widget, maturity, value)
    end
end

# Outer constructors for passing only the widget
AmericanCallOption(widget::Widget) = AmericanCallOption(;widget = widget)
AmericanCallOption(widget::Widget, maturity::Real, value::Dict{String, AbstractFloat}) =
    AmericanCallOption(;widget = widget, maturity = maturity, value = value)

struct EuroPutOption{T <: Widget} <: PutOption
    widget::T
    maturity::AbstractFloat
    value::Dict{String, AbstractFloat}

    # kwargs constructor
    function EuroPutOption(; widget, maturity = 1, value = Dict{String, AbstractFloat}())  
        value == Dict{String, AbstractFloat}() ? nothing : 
            @warn("It is not recommended to pass values through the constructor, instead 
            model!(Instrument) should be used")
        new{typeof(widget)}(widget, maturity, value)
    end
end

# Outer constructors for passing only the widget
EuroPutOption(widget::Widget) = EuroPutOption(;widget = widget)
EuroPutOption(widget::Widget, maturity::Real, value::Dict{String, AbstractFloat}) =
    EuroPutOption(;widget = widget, maturity = maturity, value = value)

struct AmericanPutOption{T <: Widget} <: PutOption
    widget::T
    maturity::AbstractFloat
    value::Dict{String, AbstractFloat}
    
    # kwargs constructor
    function AmericanPutOption(; widget, maturity = 1, value = Dict{String, AbstractFloat}())  
        value == Dict{String, AbstractFloat}() ? nothing : 
            @warn("It is not recommended to pass values through the constructor, instead 
            model!(Instrument) should be used")
        new{typeof(widget)}(widget, maturity, value)
    end
end

# Outer constructors for passing only the widget
AmericanPutOption(widget::Widget) = AmericanPutOption(;widget = widget)
AmericanPutOption(widget::Widget, maturity::Real, value::Dict{String, AbstractFloat}) =
    AmericanPutOption(;widget = widget, maturity = maturity, value = value)

# ------ Type system for futures: subtype of FinancialInstrument ------
struct Future{T <: Widget} <: FinancialInstrument 
    widget::T
    maturity::AbstractFloat
    value::Dict{String, AbstractFloat}
end

# ------ Type system for stuff we haven't figured out yet ------ 
struct ETF <: FinancialInstrument end
struct InterestRateSwap <: FinancialInstrument end

