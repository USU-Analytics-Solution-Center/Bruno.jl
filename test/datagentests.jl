# test data gen type constructor 
@testset verbose = true "input type constructor tests" begin
    @testset "test kwargs for $v" for v in (Stationary, MovingBlock, CircularBlock)
        kwargs = Dict(:n => 10, :block_size => 4)
        input = BootstrapInput([1, 2, 3, 4, 5], v; kwargs...)
        @test input.input_data == [1, 2, 3, 4, 5]
        @test input.n == 10
        @test input.block_size == 4
    end

    @testset "test for correct type" begin
        input_data = [1, 2, 3, 4, 5]
        kwargs = Dict(:n => 10, :block_size => 4.0)
        input1 = BootstrapInput(input_data, MovingBlock; kwargs...)
        input2 = BootstrapInput(input_data, CircularBlock; kwargs...)
        input3 = BootstrapInput(input_data, Stationary; kwargs...)
        @test isa(input1, BootstrapInput{MovingBlock,Int64,Float64,Int64})
        @test isa(input2, BootstrapInput{CircularBlock,Int64,Float64,Int64})
        @test isa(input3, BootstrapInput{Stationary,Int64,Float64,Int64})
    end

    @testset "Test constructor limits for $v" for v in
                                                  (MovingBlock, CircularBlock, Stationary)
        # test for size of input_data
        @test_throws ErrorException BootstrapInput(
            [1],
            v;
            n = 10,
            block_size = 1,
        )
        # test constraint for block_size
        @test_throws ErrorException BootstrapInput(
            [1, 2, 3],
            v;
            n = 10,
            block_size = 5,
        )
        @test_throws ErrorException BootstrapInput(
            [1, 2, 3],
            v;
            n = 0,
            block_size = 2,
        )
    end
end
