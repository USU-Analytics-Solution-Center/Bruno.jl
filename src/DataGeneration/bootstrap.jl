import Distributions.Geometric

abstract type TSBootMethod end
struct Stationary <: TSBootMethod end
struct MovingBlock <: TSBootMethod end
struct CircularBlock <: TSBootMethod end

"""
## Description
Contains the parameters needed to perform block bootstrap of type T to be used by getData() 
function. T can be any subtype of TSBootMethod: Stationary, MovingBlock, or CircularBlock.
These structs can be constructed directly or with the `data_gen_input()` function. 

## Syntax 
```
P = BootstrapInput{T <: TSBootMethod}(; kwargs...)
```

## Keyword Arguments
- `input_data::Array{<:Real}`: data to be resampled. Must be a 1-D array
- `n::Integer`: size of resampled output data. Default: 100
- `block_size::Integer`: block size to use. Default: 2
- `dt::Real` assumed change in time between samples in days. Default: 1.
"""
struct BootstrapInput{T <: TSBootMethod} <: DataGenInput
    input_data::Array{<:Real} # array of data to be resampled
    n::Integer # desired size of resampled data
    block_size::Float32 #desired average block size (will add more to this later)
    dt::Real # change in time between timestep in days
    
    # constructor for kwargs
    function BootstrapInput{T}(; input_data, n = 100, block_size = 10, dt = 1) where {T<:TSBootMethod}
        # check input_data is more than a single data point 
        if length(input_data) < 2
            error("input_data must have at least 2 elements") 
        end
        # check block_size is smaller than input_data 
        if length(input_data) < block_size
            error("block_length must be smaller than the size of the input_data")
        end
        if n < 1
            error("n (size of resampled data) must be greater than 0")
        end
        new(input_data, n, block_size, dt)
    end
    # constructor for inputing args in exact correct order
    function BootstrapInput{T}(input_data, n, block_size, dt) where {T<:TSBootMethod}
        if length(input_data) < 2
            error("input_data must have at least 2 elements") 
        end
        # check block_size is smaller than input_data 
        if length(input_data) < block_size
            error("block_length must be smaller than the size of the input_data")
        end
        if n < 1
            error("n (size of resampled data) must be greater than 0")
        end
        new(input_data, n, block_size, dt)
    end
end

function getData(Param::BootstrapInput{Stationary}, nSimulation::Integer=1)
    p = 1/Param.block_size
    data = zeros((Param.n, nSimulation)) 
    for run_num in 1:nSimulation
        # generates block size and starting position for first block
        block = rand(Geometric(p))
        while block == 0 || block > Param.n
            block = rand(Geometric(p))
        end
        block_counter = 0
        block_index = rand(1:length(Param.input_data))
        for i in 1:Param.n
            if block_counter < block 
                # go on indexing in the current block
                data[i, run_num] = Param.input_data[block_index]
                block_counter += 1
            else
                # make a new block and sample first index
                block = rand(Geometric(p)) 
                while block == 0 || block > Param.n
                    block = rand(Geometric(p))
                end
                block_index = rand(1:length(Param.input_data))
                data[i, run_num] = Param.input_data[block_index]
                block_counter = 1
            end

            if block_index == length(Param.input_data)
                block_index = 1 # wrap around the dataset to the start
            else
                block_index += 1
            end
        end
    end
    return data
end

function getData(Param::BootstrapInput{MovingBlock}, nSimulation::Integer=1)
    data = zeros(Param.n)
    for run_num in 1:nSimulation
        block_counter = 0
        start_index = rand(1:floor(Int, length(Param.input_data)- Param.block_size))
        for i in 1:Param.n
            if block_counter < Param.block_size 
                data[i, run_num] = Param.input_data[start_index + block_counter]
                block_counter += 1
            else
                start_index = rand(1:floor(Int, length(Param.input_data)- Param.block_size))
                data[i, run_num] = Param.input_data[start_index]
                block_counter = 1
            end
        end
    end
    return data
end

function getData(Param::BootstrapInput{CircularBlock}, nSimulation::Integer=1)
    data = zeros(Param.n)
    for run_num in 1:nSimulation
        block_counter = 0
        index_num = rand(1:length(Param.input_data))
        for i in 1:Param.n
            if block_counter < Param.block_size
                data[i, run_num] = Param.input_data[index_num]
                block_counter += 1
            else
                index_num = rand(1:length(Param.input_data))
                data[i, run_num] = Param.input_data[index_num]
                block_counter = 1
            end

            if index_num == length(Param.input_data)
                index_num = 1
            else
                index_num += 1
            end
        end
    end
    return data
end

# functions for block length - math taken part directly from block length paper
# not for the end user to ever see or use.
# PAPER NAME HERE.... DOCUMENT LATER! 

# these are for the block_length parameters, to use with multiple dispatch.
function D(g_hat, bootstrap_method::Stationary)
    2 * (g_hat ^ 2)
end

function D(g_hat, bootstrap_method::CircularBlock)
    (4 / 3) * (g_hat ^ 2)
end
D(g_hat, bootstrap_method::TSBootMethod) = D(g_hat, Circular()) # catch all other types

"""
    opt_block_length(array, bootstrap_method::TSBootMethod)

Computes the optimal block length for a time series block bootstrap using the methods defined 
by Politis and White (2004). 

If bootstrap method other than Stationary or CircularBlock is used, the function defaults 
to CircularBlock

# Example
```
using Bruno
using Distributions: Normal

#create ar(1) data set
ar1 = [1.0]
for i in _:799
    push!(ar1, ar1[end] * 0.7 + rand(Normal()))
end

#find optimal block lengths
st_bl = opt_block_length(ar1, Stationary())
cb_bl = opt_block_length(ar1, CircularBlock())
```
"""
function opt_block_length(array, bootstrap_method::TSBootMethod)
    N = size(array)[1]
    K_N = max(5,floor(Int, sqrt(log10(N))))
    # m_max from Kevin Sheppard arch package and Andrew Patton Matlab code
    m_max = ceil(Int, sqrt(N)) + K_N
    # constant to check rho array against 
    comp = 2 * sqrt( log10(N) / N)
    eps = array .- mean(array)
    # array to put autocovariances in so they don't get computed multiple times
    R = zeros(m_max + 1)
    R_0 = dot(eps, eps) / N

    m = nothing
    # finding the m and M variables from Politis paper
    for i in 1:m_max
        # compute R(i) the autocovariances
        R[i] = dot(eps[1:end-i], eps[i+1:end]) / N
        if i > K_N 
            # check rho for m = i - K_N through K_N values
            if max([abs(R[t]/ R_0) for t in (i - K_N):i]...) < comp && m === nothing
                m = i - K_N
            end
        end
    end

    m === nothing ? M = m_max : M = min(2 * max(m, 1), m_max) # check for m > max_m
    
    # figure out G for the equation
    G = 0.0
    g_hat = R_0
    for k in 1:M 
        lambda = k/M <= 1 / 2 ? 1 : 2 * (1 - (k/M))
        # G and g_hat are symmetric summations around 0, so we can just multiply each term by 2
        G += 2 * lambda * k * R[k] 
        g_hat += 2 * lambda * R[k]
    end
    b_length = ((2 * G^2)/ D(g_hat, bootstrap_method))^(1/3) * N ^ (1/3)
    return b_length
end