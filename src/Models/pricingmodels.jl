"""
## Description 
The functions needed to run a binomial tree
https://magnimetrics.com/understanding-the-binomial-option-pricing-model/
"""

function price(fin_obj::Option, pricing_model::Type{BinomialTree}, strike_price, Δt, risk_free_rate)
    println(fin_obj)
end

function get_u(ror, delta, time_steps, sigma)
    return exp((ror - delta) * time_steps + (sigma * (time_steps ^ .5)))   
end

function get_d(ror, delta, time_steps, sigma)
    return exp((ror - delta) * time_steps - (sigma * (time_steps ^ .5)))   
end

function get_p(r, q, h, u, d)
    return (exp((r - q) * h) - d) / (u - d)
end

