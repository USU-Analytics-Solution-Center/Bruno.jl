@testset "Stock Creation" begin
    # Test the stock widget creation
    
    # Test kwarg creation when vol not given
    kwargs  = (prices=[1, 2, 3, 4, 5, 4, 3, 2, 1], name="Example")
    a_widget = Stock(;kwargs...)
    @test isapprox(a_widget.volatility, .471, atol=.001)
    @test a_widget.name == "Example"
    @test a_widget.prices == [1, 2, 3, 4, 5, 4, 3, 2, 1]
    
    # Test kwarg creation when all given
    kwargs  = (prices=[1, 2, 3, 4, 5, 4, 3, 2, 1], name="Example", volatility=.05)
    a_widget = Stock(;kwargs...)
    @test a_widget.volatility == .05
    @test a_widget.name == "Example"
    @test a_widget.prices == [1, 2, 3, 4, 5, 4, 3, 2, 1]

    # Test ordered argumentes when only price given
    a_widget = Stock([1, 2, 3, 4, 5, 4, 3, 2, 1])
    @test isapprox(a_widget.volatility, .471, atol=.001)
    @test a_widget.name == ""
    @test a_widget.prices == [1, 2, 3, 4, 5, 4, 3, 2, 1]

    # Test ordered argumentes when name not given
    a_widget = Stock(prices=[1, 2, 3, 4, 5, 4, 3, 2, 1], volatility=.05)
    @test a_widget.volatility == .05
    @test a_widget.name == ""
    @test a_widget.prices == [1, 2, 3, 4, 5, 4, 3, 2, 1]

    # Test ordered argumentes when all given
    a_widget = Stock(prices=[1, 2, 3, 4, 5, 4, 3, 2, 1], volatility=.05, name="Example")
    @test a_widget.volatility == .05
    @test a_widget.name == "Example"
    @test a_widget.prices == [1, 2, 3, 4, 5, 4, 3, 2, 1]

end