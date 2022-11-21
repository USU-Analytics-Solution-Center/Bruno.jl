# active strategies that come built in with the package
function strategy(
    fin_obj::FinancialInstrument,
    pricing_model,
    strategy_mode::Type{<:Naked},
    holdings,
    step;
    kwargs...
)
    # this is the naked strategy. So we are not hedging... Just buy one of whatever and let it ride
    if step == 1
        buy(fin_obj, 1, holdings, pricing_model, kwargs[:transaction_cost]; kwargs...)
    end

    return holdings
end

function strategy(
    fin_obj::FinancialInstrument,
    pricing_model,
    strategy_mode::Type{<:StaticDeltaHedge},
    holdings,
    step;
    kwargs...
)
    if step == 1
        buy(fin_obj, 1, holdings, pricing_model, kwargs[:transaction_cost])

        delta =
            (
                log(fin_obj.widget.prices[end] / fin_obj.strike_price) +
                (fin_obj.risk_free_rate + (fin_obj.widget.volatility^2 / 2)) *
                fin_obj.maturity
            ) / (fin_obj.widget.volatility * sqrt(fin_obj.maturity))
        holdings["delta"] = delta
        sell(fin_obj.widget, delta, holdings, pricing_model, 0)  # assuming transaction_cost == 0 for stocks
    end

    return holdings
end


function strategy(
    fin_obj::CallOption,
    pricing_model,
    strategy_mode::Type{<:RebalanceDeltaHedge},
    holdings,
    step;
    kwargs...
)

    if step == 1
        buy(fin_obj, 1, holdings, pricing_model, kwargs[:transaction_cost])
    end
    if (step - 1) % kwargs[:steps_between] == 0
        delta = cdf(
            Normal(),
            (
                log(fin_obj.widget.prices[end] / fin_obj.strike_price) +
                (fin_obj.risk_free_rate + (fin_obj.widget.volatility^2 / 2)) *
                fin_obj.maturity
            ) / (fin_obj.widget.volatility * sqrt(fin_obj.maturity)),
        )
        holdings["delta"] = delta
        change = delta - abs(holdings["widget_count"])  # new - old = Change
        if change > 0  # if delta increased we want to increase the hedge
            sell(fin_obj.widget, change, holdings, pricing_model, 0)
        else  # if delta decreased we want to lessen the hedge 
            buy(fin_obj.widget, -change, holdings, pricing_model, 0)  # assuming no transaction cost for widgets. Note we flip the sign here for ease in buy
        end
    end

    return holdings
end

function strategy(
    fin_obj::PutOption,
    pricing_model,
    strategy_mode::Type{<:RebalanceDeltaHedge},
    holdings,
    step;
    kwargs...,
)
    if step == 1
        buy(fin_obj, 1, holdings, pricing_model, kwargs[:transaction_cost])
    end
    if (step - 1) % kwargs[:steps_between] == 0
        delta =
            cdf(
                Normal(),
                (
                    log(fin_obj.widget.prices[end] / fin_obj.strike_price) +
                    (fin_obj.risk_free_rate + (fin_obj.widget.volatility^2 / 2)) *
                    fin_obj.maturity
                ) / (fin_obj.widget.volatility * sqrt(fin_obj.maturity)),
            ) - 1
        holdings["delta"] = delta
        change = delta + holdings["widget_count"]  # new - old = Change
        if change > 0  # if delta increased we want to increase the hedge
            sell(fin_obj.widget, change, holdings, pricing_model, 0)
        else  # if delta decreased we want to lessen the hedge 
            buy(fin_obj.widget, -change, holdings, pricing_model, 0)  # assuming no transaction cost for widgets. Note we flip the sign here for ease in buy
        end
    end

    return holdings
end

function strategy(
    obj_array::Vector{<:FinancialInstrument},
    pricing_model,
    strategy_mode::Type{Naked},
    holdings,
    step; 
    transaction_cost=0.0,
    kwargs...
)
    # just buy one of each obj in array
    if step == 1
        for obj in obj_array
            buy(obj, 1, holdings, pricing_model, transaction_cost; kwargs...)
        end
    end

    return holdings
end

