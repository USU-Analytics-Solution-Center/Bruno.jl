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
    a_stock = Stock(41; volatility=.3)  # create a widget
    a_fin_inst =  EuroCallOption(a_stock, 40; risk_free_rate=.08) # create an Option
    price!(a_fin_inst, BinomialTree)  # add the binomial Option value to the options values
    
    # check that a value was added to a_fin_inst
    value = a_fin_inst.value["Binomial_tree"]
    @test value != Nothing

    # Check if it is the correct value
    @test  7.073 <= value <= 7.074
    
end


@testset "Euro Put Price Test 'price'" begin
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
    a_stock = Stock(41; volatility=.3)  # create a widget
    a_fin_inst = EuroPutOption(a_stock, 40; risk_free_rate=.08)  # create an Option
    price!(a_fin_inst, BinomialTree)  # add the binomial Option value to the options values
    
    # check that a value was added to a_fin_inst
    value = a_fin_inst.value["Binomial_tree"]
    @test value != Nothing

    # Check if it is the correct value
    @test  2.998 <= value <= 2.999 
    
end

@testset "American Put Price Test 'price'" begin
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
    a_stock = Stock(41; volatility=.3)  # create a widget
    a_fin_inst = AmericanPutOption(a_stock, 40; risk_free_rate=.08)  # create an Option
    price!(a_fin_inst, BinomialTree)  # add the binomial Option value to the options values
    
    # check that a value was added to a_fin_inst
    value = a_fin_inst.value["Binomial_tree"]
    @test value != Nothing

    # Check if it is the correct value
    @test  3.292 <= value <= 3.293
    
end

@testset "American Call Price Test 'price'" begin
    """
    Using "Book Name"
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
    a_stock = Stock(110; volatility=.3)  # create a widget
    a_fin_inst = AmericanCallOption(a_stock, 100; risk_free_rate=.05)  # create an Option
    price!(a_fin_inst, BinomialTree; delta=.035)  # add the binomial Option value to the options values
    
    # check that a value was added to a_fin_inst
    value = a_fin_inst.value["Binomial_tree"]
    @test value != Nothing

    # Check if it is the correct value
    @test  18.592 <= value <= 18.594
    
end

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
    stock = Stock(41; volatility = .3)
    call = EuroCallOption(stock, 40; risk_free_rate = .08, maturity = .25)
    price!(call, BlackScholes)

    @test isapprox(call.value["BlackScholes"], 3.399; atol = .01)
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
    stock = Stock(41; volatility = .3)
    put = EuroPutOption(stock, 40; risk_free_rate = .08, maturity = .25)
    price!(put, BlackScholes)

    @test isapprox(put.value["BlackScholes"], 1.607; atol = .01)
end

end
