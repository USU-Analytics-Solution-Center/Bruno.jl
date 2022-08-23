using Test
using Bruno

# Time Series Bootstrap tests 
# Moving block bootstrap 
# Test constructor
@testset verbose = true "MBB constructor tests" begin
    @testset "Normal constructor" begin
    in_data = [1,2,3,4,5]
    # normal constructor
    MBBtest = MovingBlockBootstrap(in_data, 10, 3, 1)
    @test MBBtest.input_data == in_data
    @test MBBtest.n == 10
    @test MBBtest.block_size == 3
    @test MBBtest.dt == 1.0
    end
    
    @testset "kwargs constructor" begin
    in_data = [1,2,3,4,5]
    small_kwargs = (dt = 1.0, block_size = 3)
    all_kwargs = (input_data = in_data, n = 10, dt = 1.0, block_size = 3)
    MBBtest2 = MovingBlockBootstrap(in_data, 10; small_kwargs...)
    MBBtest3 = MovingBlockBootstrap(;all_kwargs...)
    @test MBBtest2.input_data == MBBtest3.input_data && MBBtest3.input_data == in_data
    @test MBBtest2.n == MBBtest3.n 
    @test MBBtest2.block_size == MBBtest3.block_size 
    @test MBBtest2.dt == MBBtest2.dt
    end

    @testset "block size constraint" begin
        in_data = [1,2,3,4,5]
        @test_throws ErrorException MovingBlockBootstrap(in_data, 15; block_size = 10)
    end

end

@testset verbose = true "Moving Block Bootstrap getData" begin
    in_data = [1,2,3,4,5]
    MBBtest = MovingBlockBootstrap(in_data, 10; block_size = 3, dt=1)
    data = getData(MBBtest)
    @test length(data) == MBBtest.n
end
