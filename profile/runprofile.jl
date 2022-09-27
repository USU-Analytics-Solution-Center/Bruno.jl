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
    deleteat!(list_of_functions, findall(x->x=="Bruno", list_of_functions))  # remove the Bruno tag as its doesnt need to be tested
    df = DataFrame(functions=list_of_functions, time=[-1 for v in list_of_functions])  # Set up the df to have negative run times. IF a functions stays negative we know it wasnt tested
    
    generic_arguments = Dict(:prices => [151.76, 150.77, 150.43, 152.74, 153.72, 156.90, 154.48, 150.70, 152.37, 155.31, 153.84], 
                                :volatility => .05, 
                                :name => "a_name")
    known_functions = [profile_stock]  # <--- add the head of a function here after writing it
    
    # Start calling the known functions
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

As a note make sure the function in question has a chance to go through
the jit before being profiled. 

Functions calls written:

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
    Stock                   
    TSBootMethod            
    Widget                  
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
    stock = Stock(prices)

    timed = @benchmark Stock($prices);
    # println(timed.TrialEstimate)
    return ("Stock", mean(timed).time)
end