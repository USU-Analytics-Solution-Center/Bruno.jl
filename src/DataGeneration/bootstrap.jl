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

"""
    getData(Param::BootstrapInput{Stationary})
"""
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
