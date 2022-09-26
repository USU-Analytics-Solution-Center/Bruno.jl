using Distributions: Normal, cdf

"""
price(fin_obj::EuroCallOption, pricing_model::Type{BinomialTree}, tree_depth, r, strike_price, delta)

Computes the value of an European Call Option. 


# Example
```
using Bruno

a_stock = Stock(41; volatility=.3)  # create a widget
a_fin_inst = EuroCallOption(a_stock; risk_free_rate=.05, strike_price=40)  # create an Option
price!(a_fin_inst, BinomialTree)  # add the binomial Option value to the options values
```
"""
function price!(fin_obj::EuroCallOption, pricing_model::Type{BinomialTree}; tree_depth=3, delta=0)
    """ 
    EURO OPTION
    tree_depth = the depth of the tree
    r = rate of return
    strike_price = the strike price in dollars
    delta = intrest rate
    """
    r = fin_obj.risk_free_rate
    strike_price = fin_obj.strike_price
    s_0 = last(fin_obj.widget.prices)  
    sigma = fin_obj.widget.volatility
    dt = fin_obj.maturity / tree_depth

    u = get_u(r, delta, dt, sigma)  # up movement 
    d = get_d(r, delta, dt, sigma)  # down movement
    p = get_p(r, dt, u, d, delta)  # risk neutral probability of an up move
    
    c = 0
    # value of the call is a weighted average of the values at each terminal node multiplied by the corresponding probability value
    for k in tree_depth:-1:0
        p_star = (factorial(tree_depth) / (factorial(tree_depth - k) * factorial(k))) * p ^ k * (1 - p) ^ (tree_depth - k)
        term_val = s_0 * u ^ k * d ^ (tree_depth - k)
        c += max(term_val - strike_price, 0) * p_star
    end

    fin_obj.value["Binomial_tree"] = exp(-r * fin_obj.maturity) * c
end

"""
price(fin_obj::AmericanCallOption, pricing_model::Type{BinomialTree}, tree_depth, r, strike_price, delta)

Computes the value of an American Call Option. 
"""
function price!(fin_obj::AmericanCallOption, pricing_model::Type{BinomialTree}; tree_depth=3, delta=0)
    r = fin_obj.risk_free_rate
    strike_price = fin_obj.strike_price
    s_0 = last(fin_obj.widget.prices)  
    sigma = fin_obj.widget.volatility
    dt = fin_obj.maturity / tree_depth

    u = get_u(r, delta, dt, sigma)  # up movement 
    d = get_d(r, delta, dt, sigma)  # down movement
    p = get_p(r, dt, u, d, delta)  # risk neutral probability of an up move
    
    # Get terminal node p*
    a_vector = AbstractFloat[]
    for k in tree_depth:-1:0
        push!(a_vector, max(s_0 * u ^ k * d ^ (tree_depth - k) - strike_price, 0))
    end
    println(a_vector)
    to_return = 0
    
    for i in 1:tree_depth+1
        place_holder = 0
        for m in 0:tree_depth - i
            k = tree_depth - m - i
            
            cu = a_vector[m + 1]
            cd = a_vector[m + 2]
            current_node = s_0 * u ^ k * d ^ (place_holder)

            a_vector[m + 1] = max(current_node - strike_price, (p * cu + (1 - p) * cd) * exp(-r * dt))
            
            place_holder += 1
        end
        to_return = a_vector[1]
        println(a_vector)
        pop!(a_vector)

    end

    fin_obj.value["Binomial_tree"] = to_return
end

"""
price(fin_obj::EuroPutOption, pricing_model::Type{BinomialTree}, tree_depth, delta)

Computes the value of an European Put Option. 

"""
function price!(fin_obj::EuroPutOption, pricing_model::Type{BinomialTree}; tree_depth=3, delta=0)
    r = fin_obj.risk_free_rate
    strike_price = fin_obj.strike_price
    s_0 = last(fin_obj.widget.prices)  
    sigma = fin_obj.widget.volatility
    dt = fin_obj.maturity / tree_depth

    u = get_u(r, delta, dt, sigma)  # up movement 
    d = get_d(r, delta, dt, sigma)  # down movement
    p = get_p(r, dt, u, d, delta)  # risk neutral probability of an up move
    
    c = 0
    # value of the call is a weighted average of the values at each terminal node multiplied by the corresponding probability value
    for k in tree_depth:-1:0
        p_star = (factorial(tree_depth) / (factorial(tree_depth - k) * factorial(k))) * p ^ k * (1 - p) ^ (tree_depth - k)
        term_val = s_0 * u ^ k * d ^ (tree_depth - k)
        c += max(strike_price - term_val, 0) * p_star
    end

    fin_obj.value["Binomial_tree"] = exp(-r * fin_obj.maturity) * c
    
end

"""
price(fin_obj::AmericanPutOption, pricing_model::Type{BinomialTree}, tree_depth, delta)

Computes the value of an American put Option. 

"""
function price!(fin_obj::AmericanPutOption, pricing_model::Type{BinomialTree}; tree_depth=3, delta=0)
    r = fin_obj.risk_free_rate
    strike_price = fin_obj.strike_price
    s_0 = last(fin_obj.widget.prices)  
    sigma = fin_obj.widget.volatility
    dt = fin_obj.maturity / tree_depth

    u = get_u(r, delta, dt, sigma)  # up movement 
    d = get_d(r, delta, dt, sigma)  # down movement
    p = get_p(r, dt, u, d, delta)  # risk neutral probability of an up move
    
    # Get terminal node p*
    a_vector = AbstractFloat[]
    for k in tree_depth:-1:0
        push!(a_vector, max(strike_price - s_0 * u ^ k * d ^ (tree_depth - k), 0))
    end

    to_return = 0
    
    for i in 1:tree_depth+1
        place_holder = 0
        for m in 0:tree_depth - i
            k = tree_depth - m - i
            
            cu = a_vector[m + 1]
            cd = a_vector[m + 2]
            current_node = s_0 * u ^ k * d ^ (place_holder)

            a_vector[m + 1] = max(strike_price - current_node, (p * cu + (1 - p) * cd) * exp(-r * dt))
            
            place_holder += 1
        end
        to_return = a_vector[1]
        pop!(a_vector)

    end

    fin_obj.value["Binomial_tree"] = to_return
end

# helper functions
function get_p(r, dt, u, d, delta)
    (exp((r - delta) * dt) - d) / (u - d)
end

function get_u(r, delta, dt, sigma)
    exp((r - delta) * dt + sigma * sqrt(dt))
end

function get_d(r, delta, dt, sigma)
    exp((r - delta) * dt - sigma * sqrt(dt))
end


# ----- Price models for call and put options using BlackScholes
function price!(fin_obj::AbstractEuroCall, pricing_model::Type{BlackScholes})
    c1 = log(fin_obj.widget.prices[end] / fin_obj.strike_price)
    a1 = fin_obj.widget.volatility * sqrt(fin_obj.maturity)
    d1 = (c1 + (fin_obj.risk_free_rate + (fin_obj.widget.volatility ^ 2 / 2)) * fin_obj.maturity) / a1
    d2 = d1 - a1 
    value = fin_obj.widget.prices[end] * cdf(Normal(), d1) - fin_obj.strike_price *
        exp(-fin_obj.risk_free_rate * fin_obj.maturity) * cdf(Normal(), d2)

    fin_obj.value["BlackScholes"] = value
end

function price!(fin_obj::AbstractEuroPut, pricing_model::Type{BlackScholes})
    c1 = log(fin_obj.widget.prices[end] / fin_obj.strike_price)
    a1 = fin_obj.widget.volatility * sqrt(fin_obj.maturity)
    d1 = (c1 + (fin_obj.risk_free_rate + (fin_obj.widget.volatility ^ 2 / 2)) * fin_obj.maturity) / a1
    d2 = d1 - a1 
    value = fin_obj.strike_price * exp(-fin_obj.risk_free_rate * fin_obj.maturity) * cdf(Normal(), -d2) - 
        fin_obj.widget.prices[end] * cdf(Normal(), -d1)

    fin_obj.value["BlackScholes"] = value
end


# ----- Price models using Monte Carlo sims
function price!(fin_obj::Option, pricing_model::Type{MonteCarlo{LogDiffusion}};
    n_sims::Int = 100, sim_size::Int = 100)

    dt = fin_obj.maturity / sim_size
    # create the data to be used in the analysis 
    data_input = LogDiffInput(sim_size; initial = fin_obj.widget.prices[end], 
                                volatility = fin_obj.widget.volatility * sqrt(dt),
                                drift = fin_obj.risk_free_rate * dt)
    final_prices = getData(data_input, n_sims)[end,:] 
    # check for exercise or not
    value = sum(payoff(fin_obj, final_prices, fin_obj.strike_price)) / n_sims * 
        exp(-fin_obj.risk_free_rate * fin_obj.maturity)

    fin_obj.value["MC_LogDiffusion"] = value
end


function price!(fin_obj::Option, pricing_model::Type{MonteCarlo{StationaryBootstrap}}; 
                 n_sims::Int)
    
    # create the data to be used in analysis
    returns = [log(1 + (fin_obj.widget.prices[i+1] - fin_obj.widget.prices[i]) / fin_obj.widget.prices[i]) for 
        i in 1:(size(fin_obj.widget.prices)[1] - 1)]

    data_input = BootstrapInput{Stationary}(; input_data = returns, 
                                            n = size(returns)[1])
    data = getData(data_input, n_sims)
    final_prices = [fin_obj.widget.prices[end] * exp(sum(data[:,i]) * fin_obj.maturity) for i in 1:n_sims]
    # calculate the mean present value of the runs
    value = sum(payoff(fin_obj, final_prices, fin_obj.strike_price)) / n_sims * 
        exp(-fin_obj.risk_free_rate * fin_obj.maturity)

    fin_obj.value["MC_StationaryBoot"] = value
end

function payoff(type::CallOption, final_prices, strike_price)
    max.(final_prices .- strike_price, 0) 
end

function payoff(type::PutOption, final_prices, strike_price)
    max.(strike_price .- final_prices, 0)    
end


end
