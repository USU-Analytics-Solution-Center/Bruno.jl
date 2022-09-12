function factory(widget::Widget, bootstrap_method::TSBootMethod, nWidgets::Signed)
    input = BootstrapInput{typeof(bootstrap_method)}(;
                                input_data = widget.prices,
                                n = length(widget.prices),
                                block_size = opt_block_length(widget.prices, bootstrap_method),
                                dt = widget.time_delta)

    bs_data = getData(input, nWidgets)
    widget_ar = Array{Widget}
    for column in 1:nWidgets
        x = typeof(widget)(bs_data[:, column], 
                            widget.name,
                            var(bs_data[:, column]),                            
                            widget.time_delta)
        # println(x)
    return(x)
    end
    
end