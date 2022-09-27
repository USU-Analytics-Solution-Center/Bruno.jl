using Bruno
using BenchmarkTools
using DataFrames

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
    df = DataFrame(functions=list_of_functions, time=[-1 for v in list_of_functions])  # Set up the df to have negative run times. IF a functions stays negative we know it wasnt tested
    generic_arguments = Dict(:prices => [151.76, 150.77, 150.43, 152.74, 153.72, 156.90, 154.48, 150.70, 152.37, 155.31, 153.84], 
                                :volatility => .05, 
                                :name => "a_name")

    # Start calling the known functions
    known_functions = [profile_stock, profile_commodity]  # <--- add the head of a function here after writing it
    results = Dict()
    for a_function in known_functions
        name, elapsed = a_function(generic_arguments)
        results[name] = elapsed
    end
    println(results)
end

"""
Function tests below. Each function returns the name of the functions it
is testing in the first postion and the time the profiler takes in the
second.

As a note try to test the worst case. As an example if we give stock 
all struct variables it wont have to calculate the var. 

Functions calls written:
    Stock

Functions calls to be written:
    AbstractAmericanCall    
    AbstractAmericanPut     
    AbstractEuroCall        
    AbstractEuroPut         
    AmericanCallOption      
    AmericanPutOption       
    BinomialTree            
    BlackScholes            
    Bond                    
    BootstrapInput          
    CallOption              
    CircularBlock           
    CircularBlockBootstrap  
    Commodity               
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
    factory                 
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