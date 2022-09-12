# financial instruments that can be passed to simulate. They house underlying widgets as part
# of the insturment. Ex: Stock call options house an underlying stock

abstract type FinancialInstrument end

# ----- Type system for options: subtype of FinancialInstrument ------
abstract type Option <: FinancialInstrument end
struct CallOption <: Option 
    widget::Widget
    maturity::AbstractFloat
    value::Dict{String, AbstractFloat}
end

struct PutOption <: Option
    widget::Widget
    maturity::AbstractFloat
    value::Dict{String, AbstractFloat}
end

# ------ Type system for futures: subtype of FinancialInstrument ------
struct Future <: FinancialInstrument 
    widget::Widget
    maturity::AbstractFloat
    value::Dict{String, AbstractFloat}
end

# ------ Type system for stuff we haven't figured out yet ------ 
struct ETF <: FinancialInstrument end
struct InterestRateSwap <: FinancialInstrument end

