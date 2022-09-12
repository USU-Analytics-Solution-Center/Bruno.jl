function factor(widget::Widget, bootstrap_method::TSBootMethod, nWidgets::Signed)
    input = BootstrapInput{bootstrap_method}(;
                                input_data = widget.prices,
                                n = length(widget.prices),
                                block_size = opt_block_length(widget.prices, bootstrap_method),
                                dt = widget.dt)

    bs_data = getData(input, nWidgets)
    widget_ar = Array{Widget}
    for column in 1:nWidgets
        push!(widget_ar, typeof(widget)(bs_data[!, column], 
                            widget.name,
                            widget.volatility,
                            widget.time_delta))
    end

    return widget_ar
end