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
    println("currently under dev")
    println(fin_obj)
    0
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
    println("currently under dev")
    println(fin_obj)
    0
end