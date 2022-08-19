import Distributions.Geometric

abstract type TSBootMethod end

"""
## Description
Contains the parameters needed to perform a stationary bootstrap (Politis and Romano, 1994)
with geometrically distributed block sizes. 

## Syntax 
```
P = StationaryBootstrap(input_data, n; kwargs...)
```

## Positional Inputs 
- `input_data`: data to be resampled. Must be a 1-D array
- `n::Integer`: size of resampled output data

## Keyword Arguments
- `block_size::Float32`: average block size to use. Default: 2.0.
- `dt::Real` assumed change in time between samples in days. Default: 1.
"""
struct StationaryBootstrap <: TSBootMethod 
    input_data # array of data to be resampled
    n::Integer # desired size of resampled data
    block_size::Float32 #desired average block size (will add more to this later)
    dt::Real # change in time between timestep in days
    StationaryBootstrap(input_data, n; block_size=2.0, dt=1) = 
        new(input_data, n, block_size, dt)
    StationaryBootstrap(input_data, n, block_size, dt) =
        new(input_data, n, block_size, dt)
    StationaryBootstrap(;input_data, n, block_size, dt) = 
        new(input_data, n, block_size, dt) 
end

"""
## Description
Contains the parameters needed to perform a moving block bootstrap without
wraparound as introduced by Kunsh (1989). To be used by getData() function.

## Syntax 
```
P = MovingBlockBootstrap(input_data, n; kwargs...)
```

## Positional Inputs 
- `input_data`: data to be resampled. Must be a 1-D array
- `n::Integer`: size of resampled output data

## Keyword Arguments
- `block_size::Integer`: block size to use. Default: 2
- `dt::Real` assumed change in time between samples in days. Default: 1.
"""
struct MovingBlockBootstrap <: TSBootMethod 
    input_data
    n::Integer
    block_size::Integer
    dt::Real
    MovingBlockBootstrap(input_data, n; block_size=10, dt=1) = 
        new(input_data, n, block_size, dt)
    MovingBlockBootstrap(input_data, n, block_size, dt) = 
        new(input_data, n, block_size, dt)
end

"""
## Description
Contains the parameters needed to perform a circular block bootstrap (bootstrap with 
wrapping). To be used by getData() function.

## Syntax 
```
P = CircularBlockBootstrap(input_data, n; kwargs...)
```

## Positional Inputs 
- `input_data`: data to be resampled. Must be a 1-D array
- `n::Integer`: size of resampled output data

## Keyword Arguments
- `block_size::Integer`: block size to use. Default: 2
- `dt::Real` assumed change in time between samples in days. Default: 1.
"""
struct CircularBlockBootstrap <: TSBootMethod 
    input_data
    n::Integer
    block_size::Integer
    dt::Real
    CircularBlockBootstrap(input_data, n; block_size=10, dt=1) = 
        new(input_data, n, block_size, dt)
    CircularBlockBootstrap(input_data, n, block_size, dt) = 
        new(input_data, n, block_size, dt)
end

function getData(Param::StationaryBootstrap, nSimulation::Integer=1)
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

function getData(Param::MovingBlockBootstrap, nSimulation::Integer=1)
    data = zeros(Param.n)
    for run_num in 1:nSimulation
        block_counter = 0
        start_index = rand(1:(length(Param.input_data)- Param.block_size))
        for i in 1:Param.n
            if block_counter < Param.block_size 
                data[i, run_num] = Param.input_data[start_index + block_counter]
                block_counter += 1
            else
                start_index = rand(1:(length(Param.input_data) - Param.block_size))
                data[i, run_num] = Param.input_data[start_index]
                block_counter = 1
            end
        end
    end
    return data
end

function getData(Param::CircularBlockBootstrap, nSimulation::Integer=1)
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
