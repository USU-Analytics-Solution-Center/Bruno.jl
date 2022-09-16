function factory(widget::Widget, bootstrap_method::TSBootMethod, nWidgets::Signed)
    fields = field_exclude(widget)

    input = BootstrapInput{typeof(bootstrap_method)}(;
                                input_data = widget.prices,
                                n = length(widget.prices),
                                block_size = opt_block_length(widget.prices, bootstrap_method)
                                )

    bs_data = getData(input, nWidgets)
    widget_ar = Vector{Widget}()
    kwargs = NamedTuple(fields .=> getfield.(Ref(widget), fields))
    for column in 1:nWidgets
        push!(widget_ar, typeof(widget)(;prices = bs_data[:, column], kwargs...))
    end
    return(widget_ar)
end

function field_exclude(widget::Widget)
    [p for p in fieldnames(typeof(widget)) if p ∉ (:prices)]
end

function field_exclude(widget::Stock)
    [p for p in fieldnames(typeof(widget)) if p ∉ (:prices, :volatility)]
end