"""
factory(widget::Widget, bootstrap_method::TSBootMethod, nWidgets::Signed)

Creates nWidgets using a given bootstrap_method. If a widget of type "Stock" is passed
in then the widget factory will use a given bootstrap method to produce n "Stock" widgets.
All widgets use first difference.

## Positional Inputs
- `widget::Widget`: A concrete widget struct. See the Widget documentation for more.
- `bootstrap_method::TSBootMethod`: A subtype of TSBootMethod: Stationary, MovingBlock, or CircularBlock.
- `nWidgets::Signed`: The amount of widgets you want widget factory to return.


# Example
```julia
prices = [1,2,5,9,8,10,5,3];
widget = Stock(prices)

list_of_widgets = factory(widget, Stationary, 2)
```
"""
function factory(widget::Widget, bootstrap_method::Type{<:TSBootMethod}, nWidgets::Signed)
    fields = field_exclude(widget)
    # take the first difference to get to returns
    returns = [widget.prices[i+1] - widget.prices[i] for i in 1:(size(widget.prices)[1] - 1)]

    # bootstrap the returns
    input = BootstrapInput{bootstrap_method}(;
                                input_data = returns,
                                n = length(returns),
                                block_size = opt_block_length(widget.prices, bootstrap_method)
                                )
    bs_data = makedata(input, nWidgets)

    # Create a vector of widgets
    widget_ar = Vector{Widget}()
    kwargs = Dict(fields .=> getfield.(Ref(widget), fields))
    for column in 1:nWidgets
        # take the returns back to prices
        prices = [widget.prices[1]]
        for i in 1:length(returns)
            push!(prices, prices[end] + bs_data[i,column])
        end

        # Add a new widget to the return vector 
        push!(widget_ar, typeof(widget)(;prices = prices, kwargs...))
    end
    return(widget_ar)
end

function factory(fin_instrument::FinancialInstrument, 
                bootstrap_method::Type{<:TSBootMethod}, 
                nInstruments::Signed) 
    fields = field_exclude(fin_instrument)
    widget_ar = factory(fin_instrument.widget, bootstrap_method, nInstruments)

    # array for all the instruments 
    instr_ar = Vector{FinancialInstrument}()
    kwargs = NamedTuple(fields .=> getfield.(Ref(fin_instrument), fields))
    for i in 1:nInstruments
        push!(instr_ar, typeof(fin_instrument)(;widget = widget_ar[i], kwargs...))
    end
    return(instr_ar)
end

# field_exclude functions are used to execlude specific struct attributes
# from the factory and leave each struct to figure out those feilds in
# their own constructor

function field_exclude(widget::Widget)
    [p for p in fieldnames(typeof(widget)) if p ∉ [:prices]]
end

function field_exclude(widget::Stock)
    [p for p in fieldnames(typeof(widget)) if p ∉ [:prices, :volatility]]
end

function field_exclude(instr::FinancialInstrument)
    [p for p in fieldnames(typeof(instr)) if p ∉ [:widget]]
end

