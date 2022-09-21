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
    a_fin_inst = EuroCallOption(a_stock)  # create an Option
    price!(a_fin_inst, BinomialTree; r=.08, strike_price= 40)  # add the binomial Option value to the options values
    
    # check that a value was added to a_fin_inst
    value = a_fin_inst.value["Binomial_tree"]
    @test value != Nothing

    # Check if it is the correct value
    @test  7.073 <= value <= 7.074 
    
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
    a_fin_inst = AmericanPutOption(a_stock)  # create an Option
    price!(a_fin_inst, BinomialTree; r=.08, strike_price= 40)  # add the binomial Option value to the options values
    
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
    a_fin_inst = AmericanCallOption(a_stock)  # create an Option
    price!(a_fin_inst, BinomialTree; r=.05, strike_price= 100, delta=.035)  # add the binomial Option value to the options values
    
    # check that a value was added to a_fin_inst
    value = a_fin_inst.value["Binomial_tree"]
    @test value != Nothing

    # Check if it is the correct value
    @test  18.592 <= value <= 18.594
    
end