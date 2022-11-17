import Bruno.BackTest: buy, sell
using Logging

@testset verbose=true "Hedging and strategy tests" begin
    
@testset "buy function tests" begin
    @testset "buy without transaction costs" begin
        test_stock = Stock(41; name = "test", volatility = 0.3)  
        test_call = EuroCallOption(test_stock, 40; label = "test_call", risk_free_rate = 0.08, maturity = 0.25)
        # the price!() of this call should be 3.399 (see pricingmodel tests)
        holdings = Dict("cash" => 10.0, "test_call" => 1, "test" => 1)
        # buy call without transaction costs
        buy(test_call, 1, holdings, BlackScholes)
        
        @test isapprox(holdings["cash"], 6.6009, atol = .001)
        @test holdings["test_call"] == 2
        @test holdings["test"] == 1

        # buy stock without transaction cost
        buy(test_stock, 1, holdings, BlackScholes)

        @test isapprox(holdings["cash"], -34.39991, atol = .001)
        @test holdings["test_call"] == 2
        @test holdings["test"] == 2
    end

    @testset "buy with transaction_costs" begin
        test_stock = Stock(41; name = "test", volatility = 0.3)  
        test_call = EuroCallOption(test_stock, 40; label = "test_call", risk_free_rate = 0.08, maturity = 0.25)
        # the price!() of this call should be 3.399 (see pricingmodel tests)
        holdings = Dict("cash" => 10.0, "test_call" => 1, "test" => 1)
        # buy call without transaction costs
        buy(test_call, 1, holdings, BlackScholes, 1)
        
        @test isapprox(holdings["cash"], 5.6009, atol = .001)
        @test holdings["test_call"] == 2
        @test holdings["test"] == 1

        # buy stock without transaction cost
        buy(test_stock, 1, holdings, BlackScholes, 1)

        @test isapprox(holdings["cash"], -36.39991, atol = .001)
        @test holdings["test_call"] == 2
        @test holdings["test"] == 2
    end

    @testset "buy function limitations" begin
        test_stock = Stock(41; name = "test", volatility = 0.3)  
        test_call = EuroCallOption(test_stock, 40; label = "test_call", risk_free_rate = 0.08, maturity = 0.25)
        holdings = Dict("cash" => 10.0, "test_call" => 1, "test" => 1)
        # buying negative widget
        @test_logs (:warn,"unable to buy negative amounts. Use sell instead") buy(test_stock, -1, holdings, BlackScholes)
        @test_logs (:warn,"unable to buy negative amounts. Use sell instead") buy(test_stock, -1, holdings, BlackScholes, 1)
        # buying negative FinancialInstrument
        @test_logs (:warn,"unable to buy negative amounts. Use sell instead") min_level=Logging.Warn buy(test_call, -1, holdings, BlackScholes)
        @test_logs (:warn,"unable to buy negative amounts. Use sell instead") buy(test_call, -1, holdings, BlackScholes, 1)

        # buying expired FinancialInstrument
        expired_call = EuroCallOption(test_stock, 40; label = "test_call", risk_free_rate = 0.08, maturity = 0.0)
        @test_logs (:warn, "unable to buy expired FinancialInstrument") buy(expired_call, 1, holdings, BlackScholes, 1)
    end
end

@testset "sell function tests" begin
    @testset "sell without transaction costs" begin
        test_stock = Stock(41; name = "test", volatility = 0.3)  
        test_call = EuroCallOption(test_stock, 40; label = "test_call", risk_free_rate = 0.08, maturity = 0.25)
        # the price!() of this call should be 3.399 (see pricingmodel tests)
        holdings = Dict("cash" => 10.0, "test_call" => 1, "test" => 1)
        # sell call without transaction costs
        sell(test_call, 1, holdings, BlackScholes)
        
        @test isapprox(holdings["cash"], 13.399, atol = .001)
        @test holdings["test_call"] == 0
        @test holdings["test"] == 1

        # sell stock without transaction cost
        sell(test_stock, 1, holdings, BlackScholes)

        @test isapprox(holdings["cash"], 54.399, atol = .001)
        @test holdings["test_call"] == 0
        @test holdings["test"] == 0
    end

    @testset "sell with transaction_costs" begin
        test_stock = Stock(41; name = "test", volatility = 0.3)  
        test_call = EuroCallOption(test_stock, 40; label = "test_call", risk_free_rate = 0.08, maturity = 0.25)
        # the price!() of this call should be 3.399 (see pricingmodel tests)
        holdings = Dict("cash" => 10.0, "test_call" => 1, "test" => 1)
        # sell call without transaction costs
        sell(test_call, 1, holdings, BlackScholes, 1)
        
        @test isapprox(holdings["cash"], 12.399, atol = .001)
        @test holdings["test_call"] == 0
        @test holdings["test"] == 1

        # sell stock without transaction cost
        sell(test_stock, 1, holdings, BlackScholes, 1)

        @test isapprox(holdings["cash"], 52.399, atol = .001)
        @test holdings["test_call"] == 0
        @test holdings["test"] == 0
    end

    @testset "sell function limitations" begin
        test_stock = Stock(41; name = "test", volatility = 0.3)  
        test_call = EuroCallOption(test_stock, 40; label = "test_call", risk_free_rate = 0.08, maturity = 0.25)
        holdings = Dict("cash" => 10.0, "test_call" => 1, "test" => 1)
        # sell negative widget
        @test_logs (:warn,"unable to sell negative amounts. Use buy instead") sell(test_stock, -1, holdings, BlackScholes)
        @test_logs (:warn,"unable to sell negative amounts. Use buy instead") sell(test_stock, -1, holdings, BlackScholes, 1)
        # sell negative FinancialInstrument
        @test_logs (:warn,"unable to sell negative amounts. Use buy instead") min_level=Logging.Warn sell(test_call, -1, holdings, BlackScholes)
        @test_logs (:warn,"unable to sell negative amounts. Use buy instead") sell(test_call, -1, holdings, BlackScholes, 1)

        # sell expired FinancialInstrument
        expired_call = EuroCallOption(test_stock, 40; label = "test_call", risk_free_rate = 0.08, maturity = 0.0)
        @test_logs (:warn, "unable to sell expired FinancialInstrument") sell(expired_call, 1, holdings, BlackScholes, 1)
    end
end

end # master hedging/ strategy testset 