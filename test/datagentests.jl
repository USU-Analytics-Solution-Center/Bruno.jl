# test data gen type constructor 
@testset verbose = true "type constructor tests" begin
    @testset "test kwargs for $v" for v in (Stationary, MovingBlock, CircularBlock)
        kwargs = Dict(:input_data => [1, 2, 3, 4, 5], :n => 10, :block_size => 4)
        input = BootstrapInput{v}(; kwargs...)
        @test input.input_data == [1, 2, 3, 4, 5]
        @test input.n == 10
        @test input.block_size == 4
    end

    @testset "test for correct type" begin
        kwargs = Dict(:input_data => [1, 2, 3, 4, 5], :n => 10, :block_size => 4)
        input1 = BootstrapInput{MovingBlock}(; kwargs...)
        input2 = BootstrapInput{CircularBlock}(; kwargs...)
        input3 = BootstrapInput{Stationary}(; kwargs...)
        @test isa(input1, BootstrapInput{MovingBlock})
        @test isa(input2, BootstrapInput{CircularBlock})
        @test isa(input3, BootstrapInput{Stationary})
    end

    @testset "Test constructor limits for $v" for v in
                                                  (MovingBlock, CircularBlock, Stationary)
        # test for size of input_data
        @test_throws ErrorException BootstrapInput{v}(;
            input_data = [1],
            n = 10,
            block_size = 1,
        )
        # test constraint for block_size
        @test_throws ErrorException BootstrapInput{v}(;
            input_data = [1, 2, 3],
            n = 10,
            block_size = 5,
        )
        @test_throws ErrorException BootstrapInput{v}(;
            input_data = [1, 2, 3],
            n = 0,
            block_size = 2,
        )
    end
end
