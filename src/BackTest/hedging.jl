using Distributions


function strategy_returns(
    obj::FinancialInstrument,
    pricing_model,
    strategy_type,
    future_prices,
    n_timesteps,
    timesteps_per_period,
    cash_injection::AbstractFloat = 0,
    fin_obj_count::AbstractFloat = 0,
    widget_count::AbstractFloat = 0,
    pay_int_rate::AbstractFloat = 0,
    hold_return_int_rate::AbstractFloat = 0;
    kwargs...
) 
    # make some checks
    length(future_prices) < n_timesteps ?
    error("not enough future prices to accomidate the given amount of time steps.") :
    nothing

    # set up the function  
    future_prices = deepcopy(future_prices)  # we do deep copies so the objects out of scope arent stomped on
    obj = deepcopy(obj)

    # set up holdings dictionary. holdings is the active holdings of the program while ts_holdings produces a history

    holdings = Dict(
        "cash" => cash_injection,
        "$(obj.label)" => fin_obj_count,
        "$(obj.widget.name)" => widget_count,
    )
    ts_holdings = Dict(
        "cash" => [cash_injection],
        "$(obj.label)" => [fin_obj_count],
        "$(obj.widget.name)" => [widget_count],
    )

    for step = 1:n_timesteps  # preform a strat for given time steps
        holdings = strategy(obj, pricing_model, strategy_type, holdings, step; kwargs...)  # do the strategy

        # updatae the snapshot of holdings for time series analysis
        for (key, value) in holdings
            push!(ts_holdings[key], value)
        end

        # pay / get interest off cash holdings
        if holdings["cash"] >= 0
            holdings["cash"] *= exp(hold_return_int_rate / timesteps_per_period)
        else
            holdings["cash"] *= exp(pay_int_rate / timesteps_per_period)
        end

        obj = update_obj(
            obj,
            strategy_type,
            pricing_model,
            holdings,
            future_prices,
            n_timesteps,
            timesteps_per_period,
            step
        )
    end

    # unwind the postions
    holdings = unwind(obj, pricing_model, holdings)
    # update holdings one last time
    for (key, value) in holdings
        push!(ts_holdings[key], value)
    end

    return holdings["cash"], ts_holdings, obj
end

# converter function to let users imput whatever type of number they want
function strategy_returns(
    obj::FinancialInstrument,
    pricing_model,
    strategy_type,
    future_prices,
    n_timesteps,
    timesteps_per_period,
    cash_injection::Real = 0,
    fin_obj_count::Real = 0,
    widget_count::Real = 0,
    pay_int_rate::Real = 0,
    hold_return_int_rate::Real = 0;
    kwargs...
)  

    cash_injection = convert(AbstractFloat, cash_injection)
    fin_obj_count = convert(AbstractFloat,fin_obj_count)
    widget_count= convert(AbstractFloat, widget_count)
    pay_int_rate = convert(AbstractFloat, pay_int_rate)
    hold_return_int_rate= convert(AbstractFloat, hold_return_int_rate)

    strategy_returns(
        obj,
        pricing_model,
        strategy_type,
        future_prices,
        n_timesteps,
        timesteps_per_period,
        cash_injection,
        fin_obj_count,
        widget_count,
        pay_int_rate,
        hold_return_int_rate;
        kwargs...
    )  
end

# for an array of fin objs
function strategy_returns(
    objs::Vector{<:FinancialInstrument},
    pricing_model,
    strategy_type,
    future_prices::Dict{String,Vector{T}},
    n_timesteps,
    timesteps_per_period,
    cash_injection = 0.0,
    fin_obj_count = Dict{String,AbstractFloat}(),
    widget_count = Dict{String,AbstractFloat}(),
    pay_int_rate = 0,
    hold_return_int_rate = 0;
    kwargs...
) where {T<:Real}

    # checks before the sim starts
    for fin_obj in objs
        try
            future_prices["$(fin_obj.widget.name)"]
        catch e
            if isa(e, KeyError)
                error(
                    "Must provide a vector of future prices for each widget of each \
                    FinancialInstrument in objs",
                )
            else
                error(
                    "Something went wrong. Make sure the future_prices Dict is set up \
                    correctly. See documentation for more information.",
                )
            end
        end
    end

    for key in keys(future_prices)
        length(future_prices[key]) < n_timesteps ?
        error(
            "Not enough future prices for $(key) to accomidate the given amount of \
            time steps.",
        ) : nothing
    end

    timesteps_per_period < 0 ? error("timesteps_per_period must be greater than 0") :
    nothing


    # Set up the needed fin objects (copy them so don't get stomped on)
    obj_array, widget_array = copy_obj(objs)

    future_prices = deepcopy(future_prices)  # we do deep copies so the objects out of scope arent stomped on


    # set up holdings dictionary. Holdings is the active holdings of the program while ts_holdings produces a history
   holdings = Dict{String, AbstractFloat}(
        "cash" => cash_injection, 
        fin_obj_count..., 
        widget_count...
    ) 
    ts_holdings = Dict("cash" => AbstractFloat[cash_injection])

    for widget in widget_array
        try
            holdings["$(widget.name)"]
        catch
            @warn("No starting amount for $(widget.name) given. Using default = 0.0")
            holdings["$(widget.name)"] = 0
        end
        ts_holdings["$(widget.name)"] = [holdings["$(widget.name)"]]
    end

    for obj in obj_array
        try
            holdings["$(obj.label)"] 
        catch
            @warn("No starting amount for $(obj.label) given. Using default = 0.0")
            holdings["$(obj.label)"] = 0
        end
        ts_holdings["$(obj.label)"] = [holdings["$(obj.label)"]]
    end

    # now do the strategy for each loop
    for step = 1:n_timesteps  # preform a strat for given time steps
        holdings =
            strategy(obj_array, pricing_model, strategy_type, holdings, step; kwargs...)  # do the strategy

        # updatae the snapshot of holdings for time series analysis
        for (key, value) in holdings
            push!(ts_holdings[key], value)
        end

        # pay / get interest off cash holdings
        if holdings["cash"] >= 0
            holdings["cash"] *= exp(hold_return_int_rate / timesteps_per_period)
        else
            holdings["cash"] *= exp(-pay_int_rate / timesteps_per_period)
        end

        # TODO figure out update obj for rolling hedge... maybe, if time
        obj_array, widget_array, holdings = update_obj(
            obj_array,
            widget_array,
            strategy_type,
            pricing_model,
            holdings,
            future_prices,
            n_timesteps,
            timesteps_per_period,
            step
        )
    end

    # unwind the postions
    holdings = unwind(obj_array, widget_array, pricing_model, holdings)

    # update ts_holdings one last time
    for (key, value) in holdings
        push!(ts_holdings[key], value)
    end

    return holdings["cash"], ts_holdings, obj_array
end

# helper for copying an array of financial objects. Keeps pointer structure the same

function copy_obj(objs::Vector{<:FinancialInstrument})
    widget_arr = []
    new_obj_arr = []
    # do first one
    first_obj = deepcopy(objs[1])
    push!(widget_arr, first_obj.widget)
    push!(new_obj_arr, first_obj)
    for i = 2:size(objs)[1]
        found = false
        # check if widget is the same as a prev widget
        for j = 1:i-1
            if objs[i].widget === objs[j].widget # check pointers
                fields = [p for p in fieldnames(typeof(objs[i])) if p ∉ [:values_library]]
                kwargs = Dict(fields .=> getfield.(Ref(objs[i]), fields))
                kwargs[:widget] = new_obj_arr[j].widget # make new widget the new made widget
                # make new object 
                new_obj = typeof(objs[i])(; kwargs...)
                push!(new_obj_arr, new_obj)
                found = true
                break # so it wont do it again for repeated widgets
            end
        end

        # didn't find one, so make a new widget
        if !found
            new_obj = deepcopy(objs[i])
            push!(widget_arr, new_obj.widget)
            push!(new_obj_arr, new_obj)
        end

    end
    return typeof(objs)(new_obj_arr), Vector{Widget}(widget_arr)
end

"""
Extra functions needed to get the hedging working
"""
function buy(
    fin_obj::FinancialInstrument,
    number::Real,
    holdings,
    pricing_model,
    transaction_cost::Real = 0.0;
    kwargs...
)
    # checks for non sensical buying
    if fin_obj.maturity == 0
        @warn("unable to buy expired FinancialInstrument")
        return holdings
    end

    if number < 0
        @warn(raw"unable to buy negative amounts. Use sell instead")
        return holdings
    end
 
    holdings["cash"] -=
        (number * Models.price!(fin_obj, pricing_model; kwargs...)) + transaction_cost
    holdings["$(fin_obj.label)"] += number

    return holdings
end

function buy(
    widget_obj::Widget, 
    number::Real, 
    holdings, 
    pricing_model, 
    transaction_cost::Real=0.0,
    kwargs...
)
    if number < 0
        @warn("unable to buy negative amounts. Use sell instead")
        return holdings
    end

    holdings["cash"] -= (number * widget_obj.prices[end]) + transaction_cost
    holdings["$(widget_obj.name)"] += number
    return holdings
end


function sell(
    fin_obj::FinancialInstrument,
    number::Real,
    holdings,
    pricing_model,
    transaction_cost::Real = 0.0;
    kwargs...
)
    if number < 0
        @warn("unable to sell negative amounts. Use buy instead")
        return holdings
    end

    if fin_obj.maturity == 0
        @warn("unable to sell expired FinancialInstrument")
        return holdings
    end
    holdings["cash"] +=
        number * Models.price!(fin_obj, pricing_model; kwargs...) - transaction_cost
    holdings["$(fin_obj.label)"] -= number

    return holdings
end

function sell(
    widget_obj::Widget, 
    number::Real, 
    holdings, 
    pricing_model, 
    transaction_cost::Real = 0.0;
    kwargs...
)
    
    # checks for negative number
    if number < 0
        @warn("unable to sell negative amounts. Use buy instead")
        return holdings
    end


    holdings["cash"] += number * widget_obj.prices[end] - transaction_cost
    holdings["$(widget_obj.name)"] -= number

    return holdings
end

function unwind(obj::FinancialInstrument, pricing_model, holdings)
    profit = 0
    if obj.maturity == 0 # should have got closed out in update_obj, but this is will catch as well
        profit += holdings["$(obj.label)"] * Models.price!(obj, Expiry)  # close out obj
        profit += holdings["$(obj.widget.name)"] * obj.widget.prices[end]  # close out hedge
    elseif obj.maturity > 0
        profit += holdings["$(obj.label)"] * Models.price!(obj, pricing_model)
        profit += holdings["$(obj.widget.name)"] * obj.widget.prices[end]  # close out hedge
    end

    holdings["$(obj.label)"] = 0
    holdings["$(obj.widget.name)"] = 0
    holdings["cash"] += profit
    return holdings
end

# function unwind(obj::Widget, holdings)
#     profit = holdings["$(obj.widget.name)"] * obj.prices[end]
#     holdings["$(obj.widget.name)"] = 0
# 
#     holdings["cash"] += profit
#     return holdings
# end

function unwind(
    obj_array::Array{<:FinancialInstrument},
    widget_array::Array{<:Widget},
    pricing_model,
    holdings
)
    # assums no transaction costs for unwinding the position
    for fin_obj in obj_array
        model_used = pricing_model
        # checks for expired fin instruments just in case 
        # (should have been found in update_obj())
        if fin_obj.maturity <= 0
            model_used = Expiry
        end
        if holdings["$(fin_obj.label)"] > 0
            holdings =
                sell(fin_obj, holdings["$(fin_obj.label)"], holdings, model_used, 0)
        elseif holdings["$(fin_obj.label)"] < 0
            holdings =
                buy(fin_obj, -holdings["$(fin_obj.label)"], holdings, model_used, 0)
        end
    end
    for widget in widget_array
        if holdings["$(widget.name)"] > 0
            holdings = sell(widget, holdings["$(widget.name)"], holdings, pricing_model, 0)
        elseif holdings["$(widget.name)"] < 0
            holdings = buy(widget, -holdings["$(widget.name)"], holdings, pricing_model, 0)
        end
    end

    return holdings
end

# single strategy_returns()
# default update_function for all financial instruments and all pricing/ strategy modes
function update_obj(
    obj::FinancialInstrument,
    strategy_type::Type{<:Hedging},
    pricing_model,
    holdings,
    future_prices,
    n_timesteps,
    timesteps_per_period,
    step
)
    
    fields = [p for p in fieldnames(typeof(obj)) if p ∉ [:values_library]]
    kwargs = Dict(fields .=> getfield.(Ref(obj), fields))
    
    # update the widget first
    kwargs[:widget] = update_obj(
        obj.widget,
        strategy_type,
        pricing_model,
        holdings,
        future_prices,
        n_timesteps,
        timesteps_per_period,
        step
    )
    # if the option has expired do cash settlement
    if (obj.maturity - (1 / timesteps_per_period)) < 0
        if holdings["$(obj.label)"] != 0
            kwargs[:maturity] = 0
            @warn("$(obj.label) has expired, it will not be able to be bought or sold")
            if holdings["$(obj.label)"] > 0
                sell(obj, holdings["$(obj.label)"], holdings, Expiry, 0)
            elseif holdings["$(obj.label)"] < 0
                buy(obj_to_change, holdings["$(obj.label)"], holdings, Expiry, 0)
            end
        end
    else
        kwargs[:maturity] = obj.maturity - (1 / timesteps_per_period)
    end
    
    new_obj = typeof(obj)(; kwargs...)
    Models.price!(new_obj, pricing_model)

    return new_obj
end

function update_obj(
    obj::Widget, 
    strategy_type::Type{<:Hedging}, 
    pricing_model, 
    holdings, 
    future_prices, 
    n_timesteps, 
    timesteps_per_period,
    step
)
    # advance prices to next time step (the top of the future_prices now becomes the bottom of historical_prices)
    add_price_value(obj, popfirst!(future_prices))
    popfirst!(get_prices(obj))  # remove the most stale price

    # changes volatility inside the widget
    fields = [p for p in fieldnames(typeof(obj))]
    kwargs = Dict(fields .=> getfield.(Ref((obj)), fields))
    kwargs[:volatility] = get_volatility(obj.prices, timesteps_per_period)

    new_obj = typeof(obj)(; kwargs...)

    return new_obj
end

# for multi strategy_returns()
# general update_obj function that will always fall back onto for multi strategy_returns()
function update_obj(
    obj_array::Vector{T},
    widget_array::Vector{<:Widget},
    strategy_type,
    pricing_model,
    holdings,
    future_prices,
    n_timesteps,
    timesteps_per_period,
    step
) where {T<:FinancialInstrument}

    # update all the widgets first
    for i = 1:length(widget_array)
        widget = widget_array[i]
        add_price_value(widget, popfirst!(future_prices["$(widget.name)"]))
        popfirst!(get_prices(widget))  # remove the most stale price

        # make a new widget and replace the old (so volatility updates)
        fields = [p for p in fieldnames(typeof(widget_array[i]))]
        kwargs = Dict(fields .=> getfield.(Ref(widget_array[i]), fields))
        kwargs[:volatility] = get_volatility(widget.prices, timesteps_per_period)

        widget_array[i] = typeof(widget)(; kwargs...)
    end

    # update all the fin_objs next
    for i = 1:length(obj_array)

        obj_to_change = obj_array[i]
        fields = [p for p in fieldnames(typeof(obj_to_change)) if p ∉ [:values_library]]
        kwargs = Dict(fields .=> getfield.(Ref(obj_to_change), fields))
        # if the option has expired do cash settlement
        if (obj_to_change.maturity - (1 / timesteps_per_period)) < 0
            if holdings["$(obj_to_change.label)"] != 0
                kwargs[:maturity] = 0
                @warn(
                    "$(obj_to_change.label) has expired, it will not be able to be bought or sold"
                )
                if holdings["$(obj_to_change.label)"] > 0
                    sell(
                        obj_to_change,
                        holdings["$(obj_to_change.label)"],
                        holdings,
                        Expiry,
                        0,
                    )
                elseif holdings["$(obj_to_change.label)"] < 0
                    buy(
                        obj_to_change,
                        holdings["$(obj_to_change.label)"],
                        holdings,
                        Expiry,
                        0,
                    )
                end
            end
        else
            kwargs[:maturity] = obj_to_change.maturity - (1 / timesteps_per_period)
        end
        new_obj = typeof(obj_to_change)(; kwargs...)
        obj_array[i] = new_obj
    end
    return obj_array, widget_array, holdings
end



#-------Custom Price!----------#
primitive type Expiry <: Model 8 end

# these are extra... really only used for hedging models
Models.price!(fin_obj::Stock) = fin_obj.prices[end]
Models.price!(fin_obj::Stock, _::Type{<:Model}) = price!(fin_obj::Stock)

# the payoff of a call option at expiry
Models.price!(fin_obj::CallOption, _::Type{Expiry}) =
    max(0, fin_obj.widget.prices[end] - fin_obj.strike_price)
Models.price!(fin_obj::PutOption, _::Type{Expiry}) =
    max(0, fin_obj.strike_price - fin_obj.widget.prices[end])

#-------Helper Functions--------#
function find_correlation_coeff(
    obj_a::Union{Stock,Commodity},
    obj_b::Union{Stock,Commodity}
)
    """
    Pearson correlation
    """
    a_average = sum(obj_a.prices) / lastindex(obj_a.prices)
    b_average = sum(obj_b.prices) / lastindex(obj_b.prices)
    cov =
        sum((obj_a.prices .- a_average) .* (obj_b.prices .- b_average)) /
        sqrt(sum((obj_a.prices .- a_average) .^ 2) * sum((obj_b.prices .- b_average) .^ 2))
    return cov
end

function find_correlation_coeff(obj_a::Union{Stock,Commodity}, obj_b::Option)
    find_correlation_coeff(obj_a, obj_b.widget)
end

function find_correlation_coeff(obj_a::Option, obj_b::Union{Stock,Commodity})
    find_correlation_coeff(obj_b, obj_a.widget)
end
