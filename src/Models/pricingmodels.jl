"""
price(fin_obj::EuroCallOption, pricing_model::Type{BinomialTree}, tree_depth, r, strike_price, delta)

Computes the value of an European Call Option. 


# Example
```
using Bruno

a_stock = Stock(41; volatility=.3)  # create a widget
a_fin_inst = EuroCallOption(a_stock)  # create an Option
price!(a_fin_inst, BinomialTree; r=.08, strike_price= 40)  # add the binomial Option value to the options values
```
"""
function price!(fin_obj::EuroCallOption, pricing_model::Type{BinomialTree}; tree_depth=3, r=0.05, strike_price, delta=0)
    """ 
    EURO OPTION
    tree_depth = the depth of the tree
    r = rate of return
    strike_price = the strike price in dollars
    delta = intrest rate
    """
    s_0 = last(fin_obj.widget.prices)  
    sigma = fin_obj.widget.volatility
    dt = fin_obj.maturity / tree_depth

    u = exp((r - delta) * dt + sigma * sqrt(dt))  # up movement 
    d = exp((r - delta) * dt - sigma * sqrt(dt))  # down movement
    p = (exp(r * dt) - d) / (u - d)  # risk neutral probability of an up move
    
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
function price!(fin_obj::AmericanCallOption, pricing_model::Type{BinomialTree}, tree_depth, r, strike_price, delta)
    s_0 = last(fin_obj.widget.prices)  
    sigma = fin_obj.widget.volatility
    dt = fin_obj.maturity / tree_depth

    u = exp((r - delta) * dt + sigma * sqrt(dt))  # up movement 
    d = exp((r - delta) * dt - sigma * sqrt(dt))  # down movement
    p = (exp(r * dt) - d) / (u - d)  # risk neutral probability of an up move
    
    # Get terminal node p*
    a_vector = AbstractFloat[]
    for k in tree_depth:-1:0
        push!(a_vector, max(s_0 - strike_price * u ^ k * d ^ (tree_depth - k), 0))
    end

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
        pop!(a_vector)

    end

    fin_obj.value["Binomial_tree"] = to_return
end

"""
price(fin_obj::EuroPutOption, pricing_model::Type{BinomialTree}, tree_depth, r, strike_price, delta)

Computes the value of an European Put Option. 

"""
function price!(fin_obj::EuroPutOption, pricing_model::Type{BinomialTree}; tree_depth=3, r=0.05, strike_price, delta=0)
    s_0 = last(fin_obj.widget.prices)  
    sigma = fin_obj.widget.volatility
    dt = fin_obj.maturity / tree_depth

    u = exp((r - delta) * dt + sigma * sqrt(dt))  # up movement 
    d = exp((r - delta) * dt - sigma * sqrt(dt))  # down movement
    p = (exp(r * dt) - d) / (u - d)  # risk neutral probability of an up move
    
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
price(fin_obj::AmericanPutOption, pricing_model::Type{BinomialTree}, tree_depth, r, strike_price, delta)

Computes the value of an American put Option. 

"""
function price!(fin_obj::AmericanPutOption, pricing_model::Type{BinomialTree}, tree_depth, r, strike_price, delta)
    s_0 = last(fin_obj.widget.prices)  
    sigma = fin_obj.widget.volatility
    dt = fin_obj.maturity / tree_depth

    u = exp((r - delta) * dt + sigma * sqrt(dt))  # up movement 
    d = exp((r - delta) * dt - sigma * sqrt(dt))  # down movement
    p = (exp(r * dt) - d) / (u - d)  # risk neutral probability of an up move
    
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
function get_p()
    (exp(r * dt) - d) / (u - d)
end

function get_u()
    exp((r - delta) * dt + sigma * sqrt(dt))
end

function get_d()
    exp((r - delta) * dt - sigma * sqrt(dt))
end