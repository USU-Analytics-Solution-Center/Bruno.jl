using Distributions: Normal, cdf

"""
    price!(fin_obj<:CallOption, pricing_model::Type{<:Model};kwargs...)

Computes the value of a given financial object. 

# Syntax
```
price!(fin_obj, PricingModelType; kwargs...)
```
key word arguments vary depending on the Pricing Model Type.

# Example
```julia
# create a base asset
a_stock = Stock(41; volatility=.3)

# create a European call option 
a_fin_inst = EuroCallOption(a_stock, 40; risk_free_rate=.05) 

# add binomial tree call value to the options value dictionary
price!(a_fin_inst, BinomialTree)  
```
"""
price!(fin_obj, pricing_model; _...) = 
    error("Cannot price $(typeof(fin_obj)) with $(typeof(pricing_model))")

"""
    price!(fin_obj::Option, pricing_model::Type{BinomialTree}; kwargs...)

price a call or put option using the binomial tree pricing method

# Arguments
- `fin_obj::Option`: the call or put option to be priced 
- `tree_depth`: number of levels to the binomial tree. Default 3.
- `delta`: the continuous dividend rate. Default 0.

# Example
```julia
# create a base asset
a_stock = Stock(41; volatility=.3)

# create a European call option 
a_fin_inst = EuroCallOption(a_stock, 40; risk_free_rate=.05) 

# add binomial tree call value to the options value dictionary
price!(a_fin_inst, BinomialTree)  
```
"""

function price!(
    fin_obj::EuroCallOption,
    pricing_model::Type{BinomialTree};
    tree_depth = 3,
    delta = 0,
    _...
)
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
    for k = tree_depth:-1:0
        p_star =
            (factorial(tree_depth) / (factorial(tree_depth - k) * factorial(k))) *
            p^k *
            (1 - p)^(tree_depth - k)
        term_val = s_0 * u^k * d^(tree_depth - k)
        c += max(term_val - strike_price, 0) * p_star
    end
    value = exp(-r * fin_obj.maturity) * c
    fin_obj.values_library["BinomialTree"] =
        Dict("value" => value, "tree_depth" => tree_depth, "delta" => delta)
    return value
end


function price!(
    fin_obj::AmericanCallOption,
    pricing_model::Type{BinomialTree};
    tree_depth = 3,
    delta = 0,
    _...
)
    r = fin_obj.risk_free_rate
    strike_price = fin_obj.strike_price
    s_0 = last(fin_obj.widget.prices)
    sigma = fin_obj.widget.volatility
    dt = fin_obj.maturity / tree_depth

    u = get_u(r, delta, dt, sigma)  # up movement 
    d = get_d(r, delta, dt, sigma)  # down movement
    p = get_p(r, dt, u, d, delta)  # risk neutral probability of an up move

    # Get terminal node p*
    a_vector = zeros(valtype(valtype(fin_obj.values_library)), tree_depth + 1)
    for k = tree_depth:-1:0
        a_vector[tree_depth-k+1] = max(s_0 * u^k * d^(tree_depth - k) - strike_price, 0)
    end
    to_return = 0

    for i = 1:tree_depth+1
        place_holder = 0
        for m = 0:tree_depth-i
            k = tree_depth - m - i

            cu = a_vector[m+1]
            cd = a_vector[m+2]
            current_node = s_0 * u^k * d^(place_holder)

            a_vector[m+1] =
                max(current_node - strike_price, (p * cu + (1 - p) * cd) * exp(-r * dt))

            place_holder += 1
        end
        to_return = a_vector[1]
    end

    fin_obj.values_library["BinomialTree"] =
        Dict("value" => to_return, "depth" => tree_depth, "delta" => delta)
    return to_return
end

function price!(
    fin_obj::EuroPutOption,
    pricing_model::Type{BinomialTree};
    tree_depth = 3,
    delta = 0,
    _...
)
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
    for k = tree_depth:-1:0
        p_star =
            (factorial(tree_depth) / (factorial(tree_depth - k) * factorial(k))) *
            p^k *
            (1 - p)^(tree_depth - k)
        term_val = s_0 * u^k * d^(tree_depth - k)
        c += max(strike_price - term_val, 0) * p_star
    end
    value = exp(-r * fin_obj.maturity) * c
    fin_obj.values_library["BinomialTree"] =
        Dict("value" => value, "depth" => tree_depth, "delta" => delta)
    return value

end

function price!(
    fin_obj::AmericanPutOption,
    pricing_model::Type{BinomialTree};
    tree_depth = 3,
    delta = 0,
    _...
)
    r = fin_obj.risk_free_rate
    strike_price = fin_obj.strike_price
    s_0 = last(fin_obj.widget.prices)
    sigma = fin_obj.widget.volatility
    dt = fin_obj.maturity / tree_depth

    u = get_u(r, delta, dt, sigma)  # up movement 
    d = get_d(r, delta, dt, sigma)  # down movement
    p = get_p(r, dt, u, d, delta)  # risk neutral probability of an up move

    # Get terminal node p*
    a_vector = zeros(valtype(valtype(fin_obj.values_library)), tree_depth + 1)
    for k = tree_depth:-1:0
        a_vector[tree_depth-k+1] = max(strike_price - s_0 * u^k * d^(tree_depth - k), 0)
    end

    to_return = 0

    for i = 1:tree_depth+1
        place_holder = 0
        for m = 0:tree_depth-i
            k = tree_depth - m - i

            cu = a_vector[m+1]
            cd = a_vector[m+2]
            current_node = s_0 * u^k * d^(place_holder)

            a_vector[m+1] =
                max(strike_price - current_node, (p * cu + (1 - p) * cd) * exp(-r * dt))

            place_holder += 1
        end
        to_return = a_vector[1]
        pop!(a_vector)

    end

    fin_obj.values_library["BinomialTree"] =
        Dict("value" => to_return, "depth" => tree_depth, "delta" => delta)
    return to_return
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
"""
    price!(fin_obj::Option, pricing_model::Type{BlackScholes})

price a European call or put option using the Black Scholes options pricing formula

# Arguments
`fin_obj::Option`: the call or put option to be priced 

# Examples
```julia
stock = Stock(41; volatility=.3)
call = EuroCallOption(stock, 40; risk_free_rate=.08, maturity=.25)
price!(call, BlackScholes)
```
"""

function price!(fin_obj::EuroCallOption{<:Widget}, pricing_model::Type{BlackScholes}; _...)
    c1 = log(fin_obj.widget.prices[end] / fin_obj.strike_price)
    a1 = fin_obj.widget.volatility * sqrt(fin_obj.maturity)
    d1 =
        (
            c1 +
            (fin_obj.risk_free_rate + (fin_obj.widget.volatility^2 / 2)) * fin_obj.maturity
        ) / a1
    d2 = d1 - a1
    value =
        fin_obj.widget.prices[end] * cdf(Normal(), d1) -
        fin_obj.strike_price *
        exp(-fin_obj.risk_free_rate * fin_obj.maturity) *
        cdf(Normal(), d2)

    fin_obj.values_library["BlackScholes"] = Dict("value" => value)
    return value
end


function price!(fin_obj::EuroPutOption{<:Widget}, pricing_model::Type{BlackScholes}; _...)
    c1 = log(fin_obj.widget.prices[end] / fin_obj.strike_price)
    a1 = fin_obj.widget.volatility * sqrt(fin_obj.maturity)
    d1 =
        (
            c1 +
            (fin_obj.risk_free_rate + (fin_obj.widget.volatility^2 / 2)) * fin_obj.maturity
        ) / a1
    d2 = d1 - a1
    value =
        fin_obj.strike_price *
        exp(-fin_obj.risk_free_rate * fin_obj.maturity) *
        cdf(Normal(), -d2) - fin_obj.widget.prices[end] * cdf(Normal(), -d1)

    fin_obj.values_library["BlackScholes"] = Dict("value" => value)
    return value
end


# ----- Price models using Monte Carlo sims
"""
    price!(fin_obj::Option, MonteCarlo{MonteCarloModel}; kwargs...)

computes the option price using Monte Carlo simulation methods with the MonteCarloModel 
specified. Note: Only European Options call be priced via Monte Carlo methods. 

`MonteCarloModel` types:
- `LogDiffusion`
- `MCBootstrap`

# Keyword arguments

## For LogDiffusion model
- `n_sims`: Number of simulations to be run. Default 100.
- `sim_size`: The number of generated steps in each simulated run. Default 100.

## For MCBootstrap model
- `n_sims`: Number of simulations to be run. Default 100
- `bootstrap_method`: block bootstrap method to be used. Must be a subtype of `TSBootMethod`. Default=`Stationary`

# Examples 
```julia
prices = [1,4,3,4,2,5,6,4,7,5];
stock = Stock(prices);
call = EuroCallOption(stock, 8);

price!(call, MonteCarlo{LogDiffusion}; n_sims=50, sim_size=250)
price!(call, MonteCarlo{MCBootstrap}; bootstrap_method=CircularBlock, n_sims=10)
```
"""
function price!(
    fin_obj::Option,
    pricing_model::Type{MonteCarlo{LogDiffusion}};
    n_sims = 100,
    sim_size = 100,
    _...
)

    dt = fin_obj.maturity / sim_size
    # create the data to be used in the analysis 
    data_input = LogDiffInput(;
        nTimeStep = sim_size,
        initial = fin_obj.widget.prices[end],
        volatility = fin_obj.widget.volatility * sqrt(fin_obj.maturity),
        drift = fin_obj.risk_free_rate * fin_obj.maturity,
    )
    final_prices = makedata(data_input, n_sims)[end, :]
    # check for exercise or not
    value =
        sum(payoff(fin_obj, final_prices, fin_obj.strike_price)) / n_sims *
        exp(-fin_obj.risk_free_rate * fin_obj.maturity)

    fin_obj.values_library["MC_LogDiffusion"] =
        Dict("value" => value, "n_sims" => n_sims, "sim_size" => sim_size)
    return value
end


function price!(
    fin_obj::Option,
    pricing_model::Type{MonteCarlo{MCBootstrap}};
    bootstrap_method = Stationary,
    n_sims = 100,
    _...
)
    length(fin_obj.widget.prices) >= 2 ? 
    nothing : 
    error("Must have multiple historical prices to bootstrap from")

    fin_obj.widget.timesteps_per_period > 0 ? 
    nothing : 
    error("Cannot have a static base asset. timesteps_per_period must be positive")

    # create the data to be used in analysis
    returns = [
        log(
            1 +
            (fin_obj.widget.prices[i+1] - fin_obj.widget.prices[i]) /
            fin_obj.widget.prices[i],
        ) for i = 1:(size(fin_obj.widget.prices)[1]-1)
    ]


    data_input =
        BootstrapInput(returns, bootstrap_method; 
            n=fin_obj.widget.timesteps_per_period - 1
        )
    data = makedata(data_input, n_sims)
    final_prices = [
        fin_obj.widget.prices[end] * exp(sum(data[:, i]) * fin_obj.maturity) for
        i = 1:n_sims
    ]
    # calculate the mean present value of the runs
    value =
        sum(payoff(fin_obj, final_prices, fin_obj.strike_price)) / n_sims *
        exp(-fin_obj.risk_free_rate * fin_obj.maturity)

    fin_obj.values_library["MC_Bootstrap{$(bootstrap_method)}"] =
        Dict("value" => value, "n_sims" => n_sims)
    return value
end

function payoff(type::CallOption, final_prices, strike_price)
    max.(final_prices .- strike_price, 0)
end

function payoff(type::PutOption, final_prices, strike_price)
    max.(strike_price .- final_prices, 0)
end
