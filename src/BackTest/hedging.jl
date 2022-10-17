function strategy_returns(obj, pricing_model, strategy_type, future_prices, n_timesteps, timesteps_per_period, 
                            cash_injection=0.0, fin_obj_count=0, widget_count=0,pay_int_rate=0, hold_return_int_rate=0; kwargs...)
    # Set up the function  
    future_prices = deepcopy(future_prices)  # we do deep copies so the objects out of scope arent stomped on
    obj = deepcopy(obj)
    length(future_prices) < n_timesteps ? error("Not enough future prices to accomidate the given amount of time steps.") : nothing
    
    # set up holdings dictionary. Holdings is the active holdings of the program while ts_holdings produces a history
    holdings = Dict("cash" => cash_injection, "fin_obj_count" => fin_obj_count, "widget_count" => widget_count)
    ts_holdings = Dict("cash" => [cash_injection], "fin_obj_count" => [fin_obj_count], "widget_count" => [widget_count])

    for step in 1:n_timesteps  # preform a strat for given time steps
        holdings = strategy(obj, pricing_model, strategy_type, holdings, step; kwargs...)  # do the strategy
        obj = update_obj(obj, strategy_type, pricing_model, n_timesteps, timesteps_per_period, step)  # if we need to mess around with maturity do it here
        
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

        # advance prices to next time step (the top of the future_prices now becomes the bottom of historical_prices)
        add_price_value(obj, popfirst!(future_prices))
        popfirst!(get_prices(obj))  # remove the most stale price

    end

    # unwind the postions
    holdings["cash"] += unwind(obj, holdings)
    # update holdings one last time
    for (key, value) in holdings
        push!(ts_holdings[key], value)
    end 

    return holdings["cash"], ts_holdings, obj
end


"""
functions Naked strategy_mode
"""
function buy(fin_obj::FinancialInstrument, number::Real, holdings, pricing_model, transaction_cost)
    holdings["cash"] -= number * Models.price!(fin_obj, pricing_model)["value"] + transaction_cost
    holdings["fin_obj_count"] += number

    return holdings
end

function buy(widget_obj::Widget, number::Real, holdings, pricing_model, transaction_cost)
    holdings["cash"] -= number * Models.price!(widget_obj, pricing_model)["value"] + transaction_cost
    holdings["widget_count"] += number

    return holdings
end

function strategy(fin_obj::FinancialInstrument, pricing_model, strategy_mode::Type{<:Naked}, holdings, step; kwargs...)
    # this is the naked strategy. So we are not hedging... Just buy one of whatever and let it ride
    if step == 1
        buy(fin_obj, 1, holdings, pricing_model, kwargs[:transaction_cost])
    end

    return holdings
end

function update_obj(obj::Option, _::Type{<:Naked}, pricing_model, _, timesteps_per_period, _)
     new_obj = typeof(obj)(;widget = obj.widget,
                          maturity = obj.maturity - (1 / timesteps_per_period),
                          risk_free_rate = obj.risk_free_rate)
    Models.price!(new_obj, pricing_model)

    return new_obj
end

function unwind(obj::FinancialInstrument, holdings)
    profit = holdings["fin_obj_count"] * Models.price!(obj, Expiry)
    holdings["fin_obj_count"] = 0
    return profit
end

function unwind(obj::Widget, holdings)
    profit = holdings["widget_count"] * obj.prices[end]
    holdings["widget_count"] = 0
    return profit
end

"""
Extra functions needed to get the hedghing working
"""
#-------Custome Price!----------#
primitive type Expiry <: Model 8 end

# these are extra... really only used for hedging models
Models.price!(fin_obj::Stock) = fin_obj.prices[end]
Models.price!(fin_obj::Stock, _::Type{<:Model}) = price!(fin_obj::Stock)

# the payoff of a call option at expiry
Models.price!(fin_obj::CallOption, _::Type{Expiry}) = max(0, fin_obj.widget.prices[end] - fin_obj.strike_price)
Models.price!(fin_obj::PutOption, _::Type{Expiry}) = max(0, fin_obj.strike_price - fin_obj.widget.prices[end])

#-------Helper Functions--------#
function find_correlation_coeff(obj_a::Union{Stock, Commodity}, obj_b::Union{Stock, Commodity})
    """
    Pearson correlation
    """
    a_average = sum(obj_a.prices) / lastindex(obj_a.prices)
    b_average = sum(obj_b.prices) / lastindex(obj_b.prices)
    cov = sum((obj_a.prices .- a_average) .* (obj_b.prices .- b_average)) / sqrt(sum((obj_a.prices .- a_average) .^ 2)  * sum((obj_b.prices .- b_average) .^ 2))
    return cov
end

function find_correlation_coeff(obj_a::Union{Stock, Commodity}, obj_b::Option)
    find_correlation_coeff(obj_a, obj_b.widget)
end

function find_correlation_coeff(obj_a::Option, obj_b::Union{Stock, Commodity})
    find_correlation_coeff(obj_b, obj_a.widget)
end