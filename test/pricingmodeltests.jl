using Random

@testset verbose=true "Pricing model tests" begin

@testset "BinomialTree price! test" begin
@testset "Euro Call Price Test 'price'" begin
    """
    Using "Book Name"
    Assumptions
        Euro Call Option
        S = 41
        K = 40
        sigma = 0.30
        r = 0.08
        T = 1
        delta = 0
    The Value of this call option should be 7.074
    """
    # Create needed values
    a_stock = Stock(41.0; volatility = 0.3)  # create a widget
    a_fin_inst = EuroCallOption(;widget = a_stock, strike_price = 40, risk_free_rate = 0.08) # create an Option
    price!(a_fin_inst, BinomialTree)  # add the binomial Option value to the options values

    # check that a value was added to a_fin_inst
    value = a_fin_inst.values_library["BinomialTree"]["value"]
    @test value != Nothing

    # Check if it is the correct value
    @test 7.073 <= value <= 7.074

end


@testset "Euro Put Price Test 'price'" begin
    """
    Using "Derivatives Markets" by Robert McDonald
    Assumptions
        Euro Call Option
        S = 41
        K = 40
        sigma = 0.30
        r = 0.08
        T = 1
        delta = 0
    The Value of this call option should be 7.074
    """
    # Create needed values
    a_stock = Stock(41.0; volatility = 0.3)  # create a widget
    a_fin_inst = EuroPutOption(;widget = a_stock, strike_price = 40, risk_free_rate = 0.08)  # create an Option
    price!(a_fin_inst, BinomialTree)  # add the binomial Option value to the options values

    # check that a value was added to a_fin_inst
    value = a_fin_inst.values_library["BinomialTree"]["value"]
    @test value != Nothing

    # Check if it is the correct value
    @test 2.998 <= value <= 2.999

end

@testset "American Put Price Test 'price'" begin
    """
    Using "Derivatives Markets" by Robert McDonald
    Assumptions
        Euro Call Option
        S = 41
        K = 40
        sigma = 0.30
        r = 0.08
        T = 1
        delta = 0
    The Value of this call option should be 7.074
    """
    # Create needed values
    a_stock = Stock(41.0; volatility = 0.3)  # create a widget
    a_fin_inst = AmericanPutOption(;widget = a_stock, strike_price = 40, risk_free_rate = 0.08)  # create an Option
    price!(a_fin_inst, BinomialTree)  # add the binomial Option value to the options values

    # check that a value was added to a_fin_inst
    value = a_fin_inst.values_library["BinomialTree"]["value"]
    @test value != Nothing

    # Check if it is the correct value
    @test 3.292 <= value <= 3.293

end

@testset "American Call Price Test 'price'" begin
    """
    Using "Derivatives Markets" by Robert McDonald
    Assumptions
        Euro Call Option
        S = 110
        K = 100
        sigma = 0.30
        r = 0.05
        T = 1
        delta = 0.035
    The Value of this call option should be 7.074
    """
    # Create needed values
    a_stock = Stock(110.0; volatility = 0.3)  # create a widget
    a_fin_inst = AmericanCallOption(;widget = a_stock, strike_price = 100, risk_free_rate = 0.05)  # create an Option
    price!(a_fin_inst, BinomialTree; delta = 0.035)  # add the binomial Option value to the options values

    # check that a value was added to a_fin_inst
    value = a_fin_inst.values_library["BinomialTree"]["value"]
    @test value != Nothing

    # Check if it is the correct value
    @test 18.592 <= value <= 18.594

end
end # test for BinomialTree

@testset verbose = true "BlackSholes price tests" begin
    @testset "EuroCallOption" begin
        """
        Using the inputs from "Derivatives Markets 3rd Edition" by Robert McDonald pg 351
        Inputs:
            Spot price: 41
            Strike price: 40
            sigma (volatility): .3
            risk free rate: 8%
            T = .25
        The call option value should be 3.399
        """
        # create underlying stock and the needed call option
        stock = Stock(41.0; volatility = 0.3)
        call = EuroCallOption(;widget = stock, strike_price = 40, risk_free_rate = 0.08, maturity = 0.25)
        price!(call, BlackScholes)

        @test isapprox(call.values_library["BlackScholes"]["value"], 3.399; atol = 0.01)
    end

    @testset "EuroPutOption" begin
        """
        Using the inputs from "Derivatives Markets 3rd Edition" by Robert McDonald pg 352
        Inputs:
            Spot price: 41
            Strike price: 40
            sigma (volatility): .3
            risk free rate: 8%
            T = .25
        The put option value should be 1.607
        """
        # create underlying stock and the needed call option
        stock = Stock(41.0; volatility = 0.3)
        put = EuroPutOption(;widget = stock, strike_price = 40, risk_free_rate = 0.08, maturity = 0.25)
        price!(put, BlackScholes)

        @test isapprox(put.values_library["BlackScholes"]["value"], 1.607; atol = 0.01)
    end

end

@testset verbose = true "MonteCarlo price tests" begin
    # This test may break with future Julia updates, just redo test with new RNG

    @testset "LogDiffusion price test" begin
        Random.seed!(78)
        test_stock = Stock(100.0; volatility = .3)
        test_call = EuroCallOption(;widget = test_stock, strike_price = 110.0, maturity=.5, risk_free_rate=.02)

        # testing with a simulation that ends with all paths out of the money
        @test price!(test_call, MonteCarlo{LogDiffusion}; sim_size=10, n_sims=3) == 0.0
        # testing with simulations that have a path that works
        # in the limit should approach Black Scholes price of 5.071
        @test isapprox(
            price!(test_call, MonteCarlo{LogDiffusion}; sim_size=10, n_sims=10_000), 
            5.07; 
            atol = .4
        )
    end

    @testset "MCBootstrap price tests" begin
        Random.seed!(78)
        test_stock = Stock([99, 97, 90, 83, 83, 88, 88, 89, 97, 100])
        test_call = EuroCallOption(;widget = test_stock, strike_price = 110, maturity=.5, risk_free_rate=.02)

        @test isapprox(
            price!(test_call, MonteCarlo{MCBootstrap}; bootstrap_method=CircularBlock, n_sims=3),
            1.50, 
            atol=.01
        )
        @test price!(test_call, MonteCarlo{MCBootstrap}; bootstrap_method=MovingBlock, n_sims=3) == 0
        @test isapprox(
            price!(test_call, MonteCarlo{MCBootstrap}; bootstrap_method=MovingBlock, n_sims=30),
            .064, 
            atol=.01
        )
        @test price!(test_call, MonteCarlo{MCBootstrap}; bootstrap_method=Stationary, n_sims=3) == 0
        @test isapprox(
            price!(test_call, MonteCarlo{MCBootstrap}; bootstrap_method=Stationary, n_sims=7),
            0.19, 
            atol=.01
        )

    end
end

end # pricing model master testset
