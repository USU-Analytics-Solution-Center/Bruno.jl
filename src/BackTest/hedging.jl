# using Statistics: std
# # "Static ratio hedging"
# # delta hedging
# # min var hedging

# # ratio= # stocks to buy : calls to buy 
# # raiio = .5 means you will be buying 1 call and 1/2 stock (or 1 stock and 1/2 call)
# # function profit(long_position::FinancialInstrument, short_position::Widget, ratio, nTimeSteps)
# #     past_prices = long_position.widget.prices
# #     future_widget_prices =  makedata(LogDiffInput(nTimeSteps, past_prices[end], long_position.widget.volatility, 0.000538), 1)
# #     fin_obj_price = price!(long_position, BlackScholes)
# #     shorting_widget_payoff(_fin_obj_price, long_position.strike_price, long_position.risk_free_rate, past_prices, future_widget_prices, ratio, nTimeSteps)
# # end

# # function shorting_widget_payoff(fin_obj_price, strike_price, risk_free_rate, past_prices, future_prices, ratio, nTimeSteps)

# #     # bought 1 option, (short) sold (ratio) * stock
# #     bank = -fin_obj_price + ratio * past_prices[end] 

# #     # call value at time t
# #     T_call_value = max(0, future_prices[end] - strike_price)

# #     # interest on money in the bank
# #     bank *= (1 + risk_free_rate)

# #     # add in money off call and buying stock
# #     bank += T_call_value - future_widget_prices[end]

# #     return bank
# # end

# # option_sign(fin_obj::fin_instrument, position= long vs short) 
# #     if true 
# #         return -1
# #     else:
# #         1

# primitive type DeltaHedge 8 end

# struct StaticRatioHedge 
#     ratio::Float
# end

# primitive type Expiry <: Model 8 end

# # these are extra... really only used for hedging models
# price!(fin_obj::Stock) = fin_obj.prices[end]
# price!(fin_obj::Stock, _::Model) = price!(fin_obj::Stock)

# # the payoff of a call option at expiry
# price!(fin_obj::CallOption, _::Expiry) = max(0, fin_obj.widget.prices[end] - fin_obj.strike_price)
# price!(fin_obj::PutOption, _::Expiry) = max(0, fin_obj.strike_price - fin_obj.widget.prices[end])


# function get_returns(obj, sign, future_prices, strategy_mode, pricing_mode)
#     # + means going long (buying) - means going short (selling)
#     if typeof(obj) == FinancialInstrument
#         if obj.value == Dict{String, AbstractFloat}() # change later...
#             @warn("No previous price initialized for the FinancialInstrument using default")
#         end
#     end

#     # initialize your position 
#     # buy or sell the obj depnding on the sign
#     bank = -sign(price!(obj_bought, pricing_mode))

#     bank = simulate(obj_bought, future_prices, strategy_mode, pricing_mode, bank, n_timesteps)

#     # unwind position - sell what you have left buy what you short sold
#     bank += sign(price!(obj_bought, _::Expiry))

#     return bank
# end


# function simulate(fin_obj::Option, future_prices, strategy_mode, pricing_mode, trading_profit, n_timesteps )
#     # how much money we get/ loose from hedging the position at each time step
#     # assums we are also closing any hedging positions at the end
#     # for buying an option

#     prev_hedging_asset_count = 0
#     for i in 1:n_timesteps
#         # gives us the "optimal" holding ratio of fin_obj to underlying asset
#         hedging_asset_count = strategy(strategy_mode, fin_obj)
#         # "sells" and "buys" fin_obj and underlyign asset to get to the holding_ratio
#         trading_profit += interest(stuff...)
#         trading_profit += rebalance(hedging_asset_count, prev_hedging_asset_count, fin_obj)
 
#         prev_hedging_asset_count = hedging_asset_count
#         push!(fin_obj.widget.prices, popfirst!(future_prices))
#         price!(fin_obj, pricing_mode)
#     end

#     # at end of the time steps sell the hedging object
#     trading_profit += hedging_asset_count * price!(fin_obj.widget, Expiry)

#     return trading_profit



# #----
# struct time 
#     n_periods::Int
#     period_type::Period
# end

# Year <: Period 
# Day <: Period 
# Month <: Period 


# #-------Helper Functions--------#
# function find_correlation_coeff(obj_a::Union{Stock, Commodity}, obj_b::Union{Stock, Commodity})
#     """
# Pearson correlation
# """
#     # Find the returns
#     # obj_a_returns = [(obj_a.prices[i + 1] - obj_a.prices[i]) / obj_a.prices[i] for i in 1:(lastindex(obj_a.prices) - 1)]
#     # obj_b_returns = [(obj_b.prices[i + 1] - obj_b.prices[i]) / obj_b.prices[i] for i in 1:(lastindex(obj_b.prices) - 1)]
#     a_average = sum(obj_a.prices) / lastindex(obj_a.prices)
#     b_average = sum(obj_b.prices) / lastindex(obj_b.prices)
#     cov = sum((obj_a.prices .- a_average) .* (obj_b.prices .- b_average)) / sqrt(sum((obj_a.prices .- a_average) .^ 2)  * sum((obj_b.prices .- b_average) .^ 2))
#     return cov
# end

# function find_correlation_coeff(obj_a::Union{Stock, Commodity}, obj_b::Option)
#     find_correlation_coeff(obj_a, obj_b.widget)
# end