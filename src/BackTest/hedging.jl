using Distributions

"""
    strategy_returns(
        obj::FinancialInstrument,
        pricing_model,
        strategy_type,
        future_prices,
        n_timesteps,
        timesteps_per_period,
        cash_injection = 0.0,
        fin_obj_count = 0.0,
        widget_count = 0.0,
        pay_int_rate = 0.0,
        hold_return_int_rate = 0.0;
        kwargs...
    )

a simulating environment to test trading or hedging strategies for given interest rates and 
and prices. To be used by providing a new method for the `strategy()` function which defines 
the trading strategy. 

Returns the dollar cumulative return from the strategy, the time-series of all holdings 
the strategy, and the updated object array. 

## Arguments
- `obj`: financial instrument the trading or hedging strategy runs on
- `pricing_model`: `Model` subtype that defines how to price the `obj`
- `strategy_type`: `Hedging` subtype that the `strategy()` function dispatches off. Must provide a new subtype for new `strategy()` methods
- `future_prices`: vector of future prices for the underlying `Widget` asset of obj to run strategy on
- `n_timesteps`: number of timesteps to test the strategy on
- `timesteps_per_period`: for the size of a timestep in the data, the number of 
time steps for a given period of time, cannot be negative. For example, if the period of 
interest is a year, and daily stock data is used, `timesteps_per_period=252`. Must be positive.
- `cash_injection`: amount of cash owned when starting the strategy 
- `fin_obj_count`: amount of financial instruments owned when starting the strategy
- `widget_count`: amount of underlying `Widget` owned when starting the strategy
- `pay_int_rate`: the continuous interest rate payed on negative cash balances
- `hold_return_int_rate`: the continous interest rate earned on positive cash balances
- `kwargs`: pass through for keyword arguments needed by `price!()` or `strategy()` functions

## Example
```
# make the Widget and FinancialInstrument to be used
stock = Stock(; prices=[99, 97, 90, 83, 83, 88, 88, 89, 97, 100], name="stock", timesteps_per_period=252)
call = EuroCallOption(stock, 110; maturity=.5, label="call", risk_free_rate=.02)

# make future_prices array
future_prices = [100, 104, 109, 105, 108, 108, 101, 101, 104, 110]

fin_obj_count = 2
widget_count = 3
pay_int_rate = .05
hold_return_int_rate = .02

cumulative_return, ts_holdings, obj = strategy_returns(
    call, 
    BlackScholes,
    Naked,
    future_prices,
    10,
    252, 
    10.0, 
    fin_obj_count, 
    widget_count,
    pay_int_rate, 
    hold_return_int_rate;
    transaction_cost = 0.0
)
```
"""
function strategy_returns(
    obj::FinancialInstrument,
    pricing_model,
    strategy_type,
    future_prices,
    n_timesteps,
    timesteps_per_period,
    cash_injection = 0.0,
    fin_obj_count = 0.0,
    widget_count = 0.0,
    pay_int_rate = 0.0,
    hold_return_int_rate = 0.0;
    kwargs...
) 
    # make some checks
    length(future_prices) < n_timesteps ?
    error("not enough future prices to accomidate the given amount of time steps.") :
    nothing

    # set up the function  
    # we do deep copies so the objects out of scope arent stomped on
    future_prices = deepcopy(future_prices)  
    obj = deepcopy(obj)

    # set up holdings dictionary. 
    # holdings is the active holdings of the program while ts_holdings produces a history

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

    # find initial value of portfolio
    initial_value = 0.0
    initial_value += cash_injection
    initial_value += holdings["$(obj.label)"] * price!(obj, pricing_model; kwargs...)
    initial_value += holdings["$(obj.widget.name)"] * obj.widget.prices[end]

    for step = 1:n_timesteps  # preform a strat for given time steps
        holdings = strategy(obj, pricing_model, strategy_type, holdings, step; kwargs...)  # do the strategy

        # updatae the snapshot of holdings for time series analysis
        for (key, value) in holdings
            try
                push!(ts_holdings[key], value)
            catch e
                if isa(e, KeyError)
                    ts_holdings[key] = [value]
                else
                    throw(e)
                end
            end
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

    return holdings["cash"] - initial_value, ts_holdings, obj
end

# for an array of fin objs
"""
    strategy_returns(
        objs::Vector{<:FinancialInstrument},
        pricing_model,
        strategy_type,
        future_prices,
        n_timesteps,
        timesteps_per_period,
        cash_injection = 0.0,
        fin_obj_count,
        widget_count,
        pay_int_rate = 0.0,
        hold_return_int_rate = 0.0;
        kwargs...
    )

a simulating environment to test trading or hedging strategies for multiple financial instruments
for given interest rates and prices. To be used by providing a new method for the 
`strategy()` function which defines the trading strategy. 

Returns the dollar cumulative return from the strategy, the time-series of all holdings 
the strategy, and the updated object array. 

## Arguments
- `objs::Vector{<:FinancialInstrument}`: vector of financial instruments the trading or hedging strategy runs on
- `pricing_model`: `Model` subtype that defines how to price the `obj`
- `strategy_type`: `Hedging` subtype that the `strategy()` function dispatches off. Must provide a new subtype for new `strategy()` methods
- `future_prices`: dictionary of vectors of future prices for underlying `Widget` assets used in financial instruments in `objs`
Note: dictionary keys must be the `widget.name` field string for each base asset
- `n_timesteps`: number of timesteps to test the strategy on
- `timesteps_per_period`: for the size of a timestep in the data, the number of 
time steps for a given period of time, cannot be negative. For example, if the period of 
interest is a year, and daily stock data is used, `timesteps_per_period=252`. Must be positive.
- `cash_injection`: amount of cash owned when starting the strategy 
- `fin_obj_count`: dictionary of amounts of financial instruments owned when starting the strategy
Note: dictionary keys must be the `FinancialInstrument.label` field string for each financial instrument
- `widget_count`: dictionary of amounts of base assets used in financial instruments owned when starting the strategy
Note: dictionary keys must be the `Widget.name` field string for each base asset
- `pay_int_rate`: the continuous interest rate payed on negative cash balances
- `hold_return_int_rate`: the continous interest rate earned on positive cash balances
- `kwargs`: pass through for keyword arguments needed by `price!()` or `strategy()` functions

## Example
```
# make the widgets and FinancialInstruments to be used
stock = Stock(; prices=[99, 97, 90, 83, 83, 88, 88, 89, 97, 100], name="stock", timesteps_per_period=252)
stock2 = Stock(; prices=[66, 61, 70, 55, 65, 63, 57, 55, 53, 68], name="stock2", timesteps_per_period=252)
call = EuroCallOption(stock, 110; maturity=.5, label="call", risk_free_rate=.02)
call2 = EuroCallOption(stock2, 70; maturity=1, label="call2", risk_free_rate=.02)
objs = [call, call2]

# make a Dict with future_prices for each widget
future_prices = Dict(
    "stock" => [100, 104, 109, 105, 108, 108, 101, 101, 104, 110],
    "stock2" => [67, 74, 73, 67, 67, 75, 69, 71, 69, 70]
)

# make dictionaries for the starting amounts held of each Widget and FinancialInstrument
fin_obj_count = Dict("call" => 1.0, "call2" => 2)
widget_count = Dict("stock" => 2.0, "stock2" => 3)
cash_injection = 0.0

pay_int_rate = 0.08
hold_return_int_rate = 0.02

cumulative_return, ts_holdings, obj_array = strategy_returns(
    objs, 
    BlackScholes,
    Naked,
    future_prices,
    10,
    252,
    cash_injection,
    fin_obj_count,
    widget_count, 
    pay_int_rate, 
    hold_return_int_rate
)
```
"""
function strategy_returns(
    objs::Vector{<:FinancialInstrument},
    pricing_model,
    strategy_type,
    future_prices,
    n_timesteps,
    timesteps_per_period,
    cash_injection = 0.0,
    fin_obj_count = Dict{String,Float64}(),
    widget_count = Dict{String,Float64}(),
    pay_int_rate = 0.0,
    hold_return_int_rate = 0.0;
    kwargs...
)

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

    n_timesteps < 1 ? error("n_timesteps must be greater than 1") :
    nothing

    # Set up the needed fin objects (copy them so don't get stomped on)
    obj_array, widget_dict = copy_obj(objs)

    future_prices = deepcopy(future_prices)  # we do deep copies so the objects out of scope arent stomped on


    # set up holdings dictionary. Holdings is the active holdings of the program while ts_holdings produces a history
   holdings = Dict(
        "cash" => cash_injection, 
        fin_obj_count..., 
        widget_count...
    ) 
    ts_holdings = Dict("cash" => [cash_injection])

    for key in keys(widget_dict)
        try
            holdings[key]
        catch
            @warn("No starting amount for $(key) given. Using default = 0.0")
            holdings[key] = 0
        end
        ts_holdings[key] = [holdings[key]]
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

    # finding initial value
    initial_value = cash_injection
    for fin_obj in obj_array
        initial_value += holdings["$(fin_obj.label)"] * price!(fin_obj, pricing_model)
    end
    for (name, widget) in widget_dict
        initial_value += holdings[name] * widget.prices[end]
    end

    # now do the strategy for each loop
    for step = 1:n_timesteps  # preform a strat for given time steps
        holdings =
            strategy(obj_array, pricing_model, strategy_type, holdings, step; kwargs...)  # do the strategy

        # update the snapshot of holdings for time series analysis
        for (key, value) in holdings
            try
                push!(ts_holdings[key], value)
            catch e
                if isa(e, KeyError)
                    ts_holdings[key] = [value]
                else
                    throw(e)
                end
            end
        end

        # pay / get interest off cash holdings
        if holdings["cash"] >= 0
            holdings["cash"] *= exp(hold_return_int_rate / timesteps_per_period)
        else
            holdings["cash"] *= exp(-pay_int_rate / timesteps_per_period)
        end

        # TODO figure out update obj for rolling hedge... maybe, if time
        obj_array, widget_dict, holdings = update_obj(
            obj_array,
            widget_dict,
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
    holdings = unwind(obj_array, widget_dict, pricing_model, holdings)

    # update ts_holdings one last time
    for (key, value) in holdings
        push!(ts_holdings[key], value)
    end

    return holdings["cash"] - initial_value, ts_holdings, obj_array, widget_dict
end

# helper for copying an array of financial objects. Keeps pointer structure the same
function copy_obj(objs)
    widget_dict = Dict{String, Widget}()
    new_obj_arr = []
    # do first one
    first_obj = deepcopy(objs[1])
    widget_dict["$(first_obj.widget.name)"] = first_obj.widget
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
            widget_dict["$(new_obj.widget.name)"] = new_obj.widget
            push!(new_obj_arr, new_obj)
        end

    end
    return typeof(objs)(new_obj_arr), widget_dict
end

# Extra functions needed to get the hedging working
"""
    buy(
        fin_obj::FinancialInstrument, 
        number,
        holdings, 
        pricing_model, 
        trasaction_cost;
        kwargs...
    )
    buy(
        fin_obj::Widget, 
        number,
        holdings, 
        pricing_model, 
        trasaction_cost;
        kwargs...
    )

Records buying a specified number of `fin_obj` in a holdings dictionary based on the given 
pricing_model. To be used in `strategy()` functions to define trading and hedging strategies.

## Arguments
- `fin_obj`: the financial object to be bought. Can be a subtype of FinancialInstrument or Widget
- `number`: number of objects to be bought
- `holdings`: dictionary with all holdings of widgets and financial instruments (generally supplied by strategy_returns() function)
- `pricing_model`: Model subtype to be used to define buy price
- `transaction_cost::Real`: total transaction costs for the transaction
- `kwargs`: pass through for any keyword arguments needed by the `pricing_model` in `price!()` function
"""
function buy(
    fin_obj::FinancialInstrument,
    number,
    holdings,
    pricing_model,
    transaction_cost = 0.0;
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
    number,
    holdings, 
    pricing_model, 
    transaction_cost = 0.0;
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

"""
    sell(
        fin_obj::FinancialInstrument, 
        number,
        holdings, 
        pricing_model, 
        trasaction_cost;
        kwargs...
    )
    sell(
        fin_obj::Widget, 
        number,
        holdings, 
        pricing_model, 
        trasaction_cost;
        kwargs...
    )

Records selling a specified number of `fin_obj` in a holdings dictionary based on the given 
pricing_model. To be used in `strategy()` functions to define trading and hedging strategies.

## Arguments
- `fin_obj`: the financial object to be sold. Can be a subtype of FinancialInstrument or Widget
- `number`: number of objects to be sold
- `holdings`: dictionary with all holdings of widgets and financial instruments (generally supplied by strategy_returns() function)
- `pricing_model`: Model subtype to be used to define sell price
- `transaction_cost`: total transaction costs for the transaction
- `kwargs`: pass through for any keyword arguments needed by the `pricing_model` in `price!()` function
"""
function sell(
    fin_obj::FinancialInstrument,
    number,
    holdings,
    pricing_model,
    transaction_cost = 0.0;
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
    number,
    holdings, 
    pricing_model, 
    transaction_cost = 0.0;
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
    obj_array::Vector{<:FinancialInstrument},
    widget_dict,
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
    for (name, widget) in widget_dict
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
    strategy_type,
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
    strategy_type, 
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
    obj_array::Vector{<:FinancialInstrument},
    widget_dict,
    strategy_type,
    pricing_model,
    holdings,
    future_prices,
    n_timesteps,
    timesteps_per_period,
    step
)

    # update all the widgets first
    for (name, widget) in widget_dict
        add_price_value(widget, popfirst!(future_prices["$(widget.name)"]))
        popfirst!(get_prices(widget))  # remove the most stale price

        # make a new widget and replace the old (so volatility updates)
        fields = [p for p in fieldnames(typeof(widget))]
        kwargs = Dict(fields .=> getfield.(Ref(widget), fields))
        kwargs[:volatility] = get_volatility(widget.prices, timesteps_per_period)

        widget_dict[name] = typeof(widget)(; kwargs...)
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
            kwargs[:widget] = widget_dict["$(obj_to_change.widget.name)"]
        new_obj = typeof(obj_to_change)(; kwargs...)
        obj_array[i] = new_obj
    end
    return obj_array, widget_dict, holdings
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
