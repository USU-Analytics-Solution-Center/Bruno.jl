primitive type DeltaHedge 8 end
primitive type Expiry <: Model 8 end

function get_returns(obj, sign, future_prices, strategy_mode, pricing_mode, n_timesteps)
    # + means going long (buying) - means going short (selling)
    if typeof(obj) <: FinancialInstrument  # Check to see if a given FinancialInstrument has been pre-loaded
        if obj.values_library == Dict{String, Dict{String, AbstractFloat}}()
            @warn("No previous price initialized for the FinancialInstrument using default")
        end
    end
    # initialize your position 
    # buy or sell the obj depnding on the sign
    bank = -sign(Models.price!(obj, pricing_mode))

    bank = simulate(obj, future_prices, strategy_mode, pricing_mode, bank, n_timesteps)

    # unwind position - sell what you have left buy what you short sold
    bank += sign(Models.price!(obj, Expiry))
    
    # return bank
end


function simulate(fin_obj::Option, future_prices, strategy_mode, pricing_mode, trading_profit, n_timesteps)
    # how much money we get/ loose from hedging the position at each time step
    # assums we are also closing any hedging positions at the end
    # for buying an option

    prev_hedging_asset_count = 0
    for i in 1:n_timesteps
        # gives us the "optimal" holding ratio of fin_obj to underlying asset
        hedging_asset_count = strategy(fin_obj, strategy_mode)
        # # "sells" and "buys" fin_obj and underlyign asset to get to the holding_ratio
        # trading_profit += interest(stuff...)
        # trading_profit += rebalance(hedging_asset_count, prev_hedging_asset_count, fin_obj)
 
        # prev_hedging_asset_count = hedging_asset_count
        # push!(fin_obj.widget.prices, popfirst!(future_prices))
        # price!(fin_obj, pricing_mode)
    end

    # # at end of the time steps sell the hedging object
    # trading_profit += hedging_asset_count * price!(fin_obj.widget, Expiry)

    return trading_profit
end

#-------strategies----------#
function strategy(fin_obj, strategy_mode::Type{one_to_one})
    return 1
end

function strategy(fin_obj, strategy_mode::Type{RatioHedging})
    return 1
end

#-------Custome Price!----------#
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
    # Find the returns
    # obj_a_returns = [(obj_a.prices[i + 1] - obj_a.prices[i]) / obj_a.prices[i] for i in 1:(lastindex(obj_a.prices) - 1)]
    # obj_b_returns = [(obj_b.prices[i + 1] - obj_b.prices[i]) / obj_b.prices[i] for i in 1:(lastindex(obj_b.prices) - 1)]
    a_average = sum(obj_a.prices) / lastindex(obj_a.prices)
    b_average = sum(obj_b.prices) / lastindex(obj_b.prices)
    cov = sum((obj_a.prices .- a_average) .* (obj_b.prices .- b_average)) / sqrt(sum((obj_a.prices .- a_average) .^ 2)  * sum((obj_b.prices .- b_average) .^ 2))
    return cov
end

function find_correlation_coeff(obj_a::Union{Stock, Commodity}, obj_b::Option)
    find_correlation_coeff(obj_a, obj_b.widget)
end