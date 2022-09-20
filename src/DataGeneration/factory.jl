function factory(widget::Widget, bootstrap_method::TSBootMethod, nWidgets::Signed)
    fields = field_exclude(widget)
    # take the first difference to get to returns
    returns = [widget.prices[i+1] - widget.prices[i] for i in 1:(size(widget.prices)[1] - 1)]

    input = BootstrapInput{typeof(bootstrap_method)}(;
                                input_data = returns,
                                n = length(returns),
                                block_size = opt_block_length(widget.prices, bootstrap_method)
                                )

    bs_data = getData(input, nWidgets)
    widget_ar = Vector{Widget}()
    kwargs = NamedTuple(fields .=> getfield.(Ref(widget), fields))
    for column in 1:nWidgets
        # take the returns back to prices
        prices = [widget.prices[1]]
        for i in 1:length(returns)
            push!(prices, prices[end] + bs_data[i,column])
        end
        push!(widget_ar, typeof(widget)(;prices = prices, kwargs...))
    end
    return(widget_ar)
end

function field_exclude(widget::Widget)
    [p for p in fieldnames(typeof(widget)) if p ∉ (:prices)]
end

function field_exclude(widget::Stock)
    [p for p in fieldnames(typeof(widget)) if p ∉ (:prices, :volatility)]
end