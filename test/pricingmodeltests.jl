@testset "Euro Call Price Test 'price'" begin
    """
    Using "Book Name"
    Assumptions
        Euro Call Option
        S = $41
        K = $40
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