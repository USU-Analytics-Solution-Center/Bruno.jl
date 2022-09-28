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

    # Deletes things that dont need to be tested like "Bruno", "Widget
    deleteat!(list_of_functions, findall(x->x=="Bruno", list_of_functions))
    deleteat!(list_of_functions, findall(x->x=="Widget", list_of_functions))
    
    # Set up
    df = DataFrame(functions=list_of_functions)  # Set up the df
    generic_arguments = Dict(:prices => [151.76, 150.77, 150.43, 152.74, 153.72, 156.90, 154.48, 150.70, 152.37, 155.31, 153.84], 
                                :volatility => .05, 
                                :name => "a_name",
                                :to_produce => 50)

    # Start calling the known functions
    known_functions = [profile_stock, profile_commodity, profile_factory, profile_bond]  # <--- add the head of a function here after writing it
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

    # Save csv to Fi
    # if isfile("foo.txt")
    #     CSV.write("example.csv", df)
    # end
    # CSV.write("results/test.csv", df)
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
    BondBond
    Bond
    factory

Functions calls to be written:
    AbstractAmericanCall    
    AbstractAmericanPut     
    AbstractEuroCall        
    AbstractEuroPut         
    AmericanCallOption      
    AmericanPutOption       
    BinomialTree            
    BlackScholes                                
    BootstrapInput          
    CallOption              
    CircularBlock           
    CircularBlockBootstrap               
    DataGenInput            
    EuroCallOption          
    EuroPutOption           
    FinancialInstrument     
    Future                  
    LogDiffInput            
    LogDiffusion            
    MonteCarlo              
    MonteCarloModel         
    MovingBlock             
    Option                  
    PutOption               
    Stationary              
    StationaryBootstrap                        
    TSBootMethod                              
    b_tree                  
    data_gen_input                           
    getData                 
    getTime                 
    opt_block_length        
    price!                  
"""

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

function profile_factory(kwargs)
    a_stock = Stock(kwargs[:prices])
    timed = @benchmark factory($a_stock, Stationary, $kwargs[:to_produce])

    return ("factory", mean(timed).time)
end