using Bruno
using BenchmarkTools
using DataFrames
using CSV
using Dates

function collect_functions(x::Module)
    results = String[]
    for i in names(x; all=false, imported=false)
        a_string = String(i)
        push!(results, String(a_string))
    end
    return results
end

function main()
    list_of_functions = collect_functions(Bruno)

    # Deletes things that dont need to be tested like "Bruno", or "Widget" as they are not functions
    obs_to_remove = ["Bruno", "Widget", "BinomialTree", "BlackScholes", "BootstrapInput", "CallOption", "Option", "DataGenInput", "getTime",
                    "FinancialInstrument", "LogDiffusion", "MonteCarlo", "MonteCarloModel", "PutOption", "StationaryBootstrap",
                    "TSBootMethod", "CircularBlockBootstrap","b_tree"]
    for name in obs_to_remove
        deleteat!(list_of_functions, findall(x->x==name, list_of_functions))
    end
    
    # Set up
    df = DataFrame(functions=list_of_functions)  # Set up the df
    generic_arguments = Dict(:prices => [151.76, 150.77, 150.43, 152.74, 153.72, 156.90, 154.48, 150.70, 152.37, 155.31, 153.84], 
                                :volatility => .05, 
                                :name => "a_name",
                                :to_produce => 50,
                                :strike_price => 150,
                                :number_of_time_steps => 100)

    # Start calling the known functions
    known_functions = [profile_stock, profile_commodity, profile_factory, profile_bond, profile_american_put,
                        profile_american_call, profile_circuler_bootstrap, profile_stationary_bootstrap,
                        profile_movingblock_bootstrap, profile_euro_call, profile_euro_put, profile_logdiffinput,
                        profile_getdata, profile_block_len]  # <--- add the head of a function here after writing it
    results = Dict()
    for a_function in known_functions
        name, elapsed = a_function(generic_arguments)
        println(name, " ", elapsed)
        results[name] = elapsed
    end

    # update df with results
    the_keys = collect(keys(results))
    new_df = DataFrame(functions=the_keys, time=[results[i] for i in the_keys])

    leftjoin!(df, new_df, on=:functions)
    replace!(df.time, missing => -1);

    CSV.write("results/" * Dates.format(now(), "yyyy-mm-dd_HH_MM_SS") * ".csv", df)
    
end

"""
Function tests below. Each function returns the name of the functions it
is testing in the first postion and the time the profiler takes in the
second.
As a note try to test the worst case. As an example if we give stock 
all struct variables it wont have to calculate the var. 
Functions calls written:
    Stock
    Commodity
    Bond
    AmericanPutOption
    AmericanCallOption
    EuroCallOption
    EuroPutOption
    CircularBlock
    Stationary
    MovingBlock
    LogDiffInput
    getData
    opt_block_length
    factory
Functions calls to be written:                                                         
    Future <-- Still under development                                                                                                     
    data_gen_input <---- Need to talk to mitch about                                                                
    price!  <---- Need to talk to mitch about                  
"""
#------Widgets------
function profile_stock(kwargs)
    prices = kwargs[:prices]

    timed = @benchmark Stock($prices);
    return ("Stock", mean(timed).time)
end

function profile_commodity(kwargs)
    prices = kwargs[:prices]

    timed = @benchmark Commodity($prices);
    return ("Commodity", mean(timed).time)
end

function profile_bond(kwargs)
    prices = kwargs[:prices]

    timed = @benchmark Bond($prices);
    return ("Bond", mean(timed).time)
end

#------FinancialInstruments------
function profile_american_put(kwargs)
    prices = kwargs[:prices]
    a_stock = Stock(prices)
    timed = @benchmark AmericanPutOption($a_stock, $kwargs[:strike_price]);
    return ("AmericanPutOption", mean(timed).time)
end

function profile_american_call(kwargs)
    prices = kwargs[:prices]
    a_stock = Stock(prices)
    timed = @benchmark AmericanCallOption($a_stock, $kwargs[:strike_price]);
    return ("AmericanCallOption", mean(timed).time)
end

function profile_euro_call(kwargs)
    prices = kwargs[:prices]
    a_stock = Stock(prices)
    timed = @benchmark EuroCallOption($a_stock, $kwargs[:strike_price]);
    return ("EuroCallOption", mean(timed).time)
end

function profile_euro_put(kwargs)
    prices = kwargs[:prices]
    a_stock = Stock(prices)
    timed = @benchmark EuroPutOption($a_stock, $kwargs[:strike_price]);
    return ("EuroPutOption", mean(timed).time)
end

#------Data Gen------
function profile_circuler_bootstrap(kwargs)
    a_stock = Stock(kwargs[:prices])
    returns = [a_stock.prices[i+1] - a_stock.prices[i] for i in 1:(size(a_stock.prices)[1] - 1)]

    # bootstrap the returns
    len = length(returns)
    opt = opt_block_length(a_stock.prices, CircularBlock)
    timed = @benchmark BootstrapInput{CircularBlock}(;input_data=$returns, n=$len, block_size=$opt)
    return ("CircularBlock", mean(timed).time)
end

function profile_stationary_bootstrap(kwargs)
    a_stock = Stock(kwargs[:prices])
    returns = [a_stock.prices[i+1] - a_stock.prices[i] for i in 1:(size(a_stock.prices)[1] - 1)]

    # bootstrap the returns
    len = length(returns)
    opt = opt_block_length(a_stock.prices, Stationary)
    timed = @benchmark BootstrapInput{Stationary}(;input_data=$returns, n=$len, block_size=$opt)
    return ("Stationary", mean(timed).time)
end

function profile_movingblock_bootstrap(kwargs)
    a_stock = Stock(kwargs[:prices])
    returns = [a_stock.prices[i+1] - a_stock.prices[i] for i in 1:(size(a_stock.prices)[1] - 1)]

    # bootstrap the returns
    len = length(returns)
    opt = opt_block_length(a_stock.prices, MovingBlock)
    timed = @benchmark BootstrapInput{MovingBlock}(;input_data=$returns, n=$len, block_size=$opt)
    return ("MovingBlock", mean(timed).time)
end

function profile_logdiffinput(kwargs)
    time_steps = kwargs[:number_of_time_steps]
    timed = @benchmark LogDiffInput($time_steps)
    return ("LogDiffInput", mean(timed).time)
end

function profile_getdata(kwargs)
    a_stock = Stock(kwargs[:prices])
    n_widgets = kwargs[:to_produce]
    returns = [a_stock.prices[i+1] - a_stock.prices[i] for i in 1:(size(a_stock.prices)[1] - 1)]

    # bootstrap the returns
    len = length(returns)
    opt = opt_block_length(a_stock.prices, MovingBlock)
    
    input = BootstrapInput{MovingBlock}(;input_data=returns, n=len, block_size=opt)
    timed = @benchmark getData($input, $n_widgets)
    return ("getData", mean(timed).time)
end

function profile_block_len(kwargs)
    prices = kwargs[:prices]
    timed = @benchmark opt_block_length($prices, $MovingBlock)
    return ("opt_block_length", mean(timed).time)
end

function profile_factory(kwargs)
    a_stock = Stock(kwargs[:prices])
    timed = @benchmark factory($a_stock, Stationary, $kwargs[:to_produce])

    return ("factory", mean(timed).time)
end
