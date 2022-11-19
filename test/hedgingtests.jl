import Bruno.BackTest: buy, sell, update_obj
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

@testset verbose=true "update_obj tests" begin
    @testset "single update_obj tests" begin
        test_stock = Stock(; prices=[99, 97, 90, 83, 83, 88, 88, 89, 97, 100], name="stock", timesteps_per_period=252)
        test_call = EuroCallOption(test_stock, 110; maturity=.5, label="call", risk_free_rate=.02)
        future_prices = [1, 2, 3]
        holdings = Dict("cash" => 0.0, "stock" => 1.0, "call" => 1.0)
        new_call = update_obj(
            test_call, 
            Naked, 
            BlackScholes,
            holdings,
            future_prices, 
            10, 
            252, 
            1
        )

        # test update_obj() worked on the widget
        @test new_call.widget.prices == [97, 90, 83, 83, 88, 88, 89, 97, 100, 1]
        @test isapprox(new_call.widget.volatility, 23.008, atol=.01)
        @test new_call.widget.name == "stock"
        @test new_call.widget.timesteps_per_period == 252

        #test update_obj() worked on the call
        @test isapprox(new_call.maturity, 0.496, atol=.01)
        @test new_call.strike_price == 110
        @test new_call.label == "call"
        @test new_call.risk_free_rate == .02
        
        # test for expiring object
        exp_call = EuroCallOption(test_stock, 1; maturity=.001, label="exp_call", risk_free_rate=.02)
        holdings["exp_call"] = 1
        @test_logs (:warn, "exp_call has expired, it will not be able to be bought or sold") update_obj(
            exp_call,
            Naked, 
            BlackScholes,
            holdings,
            future_prices, 
            10,
            252, 
            1
        )          

        @test holdings["exp_call"] == 0
        @test holdings["cash"] == 1
        
        # test that it doesn't warn on already expired fin obj 
        exp_call = EuroCallOption(test_stock, 1; maturity=0, label="exp_call", risk_free_rate=.02)
        @test_logs min_level=Logging.Warn update_obj(
            exp_call,
            Naked, 
            BlackScholes,
            holdings,
            future_prices, 
            10,
            252, 
            1
        )          
    end    

    @testset "vector update_obj() tests" begin
        test_stock = Stock(; prices=[99, 97, 90, 83, 83, 88, 88, 89, 97, 100], name="stock", timesteps_per_period=252)
        test_stock2 = Stock(; prices=[66, 61, 70, 55, 65, 63, 57, 55, 53, 68], name="stock2", timesteps_per_period=252)
        test_call = EuroCallOption(test_stock, 110; maturity=.5, label="call", risk_free_rate=.02)
        test_put = EuroPutOption(test_stock, 110; maturity=.5, label="put", risk_free_rate=.02)
        test_call2 = EuroCallOption(test_stock2, 70; maturity=1, label="call2", risk_free_rate=.02)
        test_put2 = EuroPutOption(test_stock2, 70; maturity=0.001, label="put2", risk_free_rate=.02)
        
        obj_array = [test_call, test_put, test_call2]
        obj_array2 = [test_put2] # one that should throw a warning
        widget_array = [test_stock, test_stock2]
        future_prices = Dict("stock" => [1,2,3], "stock2" => [4,5,6])
        holdings = Dict("cash" => 0, "stock" => 1, "stock2" => 2, "call" => 1, "put" => 1, "call2" => 1, "put2" => 1)
        
        new_obj_arr, new_widget_arr = update_obj(
            obj_array, 
            widget_array, 
            Naked, 
            BlackScholes, 
            holdings, 
            future_prices, 
            10,
            252, 
            1
        )

        # test widgets
        @test new_widget_arr[1].prices == [97, 90, 83, 83, 88, 88, 89, 97, 100, 1]
        @test new_widget_arr[2].prices == [61, 70, 55, 65, 63, 57, 55, 53, 68, 4]
        @test isapprox(new_widget_arr[1].volatility, 23.008, atol=.01) 
        @test isapprox(new_widget_arr[2].volatility, 14.378, atol=.01) 
        @test new_widget_arr[1].name == "stock"
        @test new_widget_arr[2].name == "stock2"

        #test obj array
        @test isapprox(new_obj_arr[1].maturity , 0.496, atol=.01)
        @test new_obj_arr[1].strike_price == 110
        @test new_obj_arr[1].label == "call"
        @test new_obj_arr[1].risk_free_rate == .02
        @test isapprox(new_obj_arr[2].maturity , 0.496, atol=.01)
        @test new_obj_arr[2].strike_price == 110
        @test new_obj_arr[2].label == "put"
        @test new_obj_arr[2].risk_free_rate == .02
        @test isapprox(new_obj_arr[3].maturity , 0.996, atol=.01)
        @test new_obj_arr[3].strike_price == 70
        @test new_obj_arr[3].label == "call2"
        @test new_obj_arr[3].risk_free_rate == .02

        @test_logs (:warn, "put2 has expired, it will not be able to be bought or sold") update_obj(
            obj_array2, 
            widget_array, 
            Naked, 
            BlackScholes, 
            holdings, 
            future_prices, 
            10,
            252, 
            1
        )
        @test holdings["put2"] == 0
        @test holdings["cash"] == 65

        # test that doesn't throw warning a second time (if holdings != 0)
        test_put2 = EuroPutOption(test_stock2, 70; maturity=0, label="put2", risk_free_rate=.02)
        obj_array2 = [test_put2]
        @test_logs min_level=Logging.Warn update_obj(
            obj_array2, 
            widget_array, 
            Naked, 
            BlackScholes, 
            holdings, 
            future_prices, 
            10,
            252, 
            1
        )
    end
end

@testset verbose=true "unwind tests" begin
   @test true 
end

@testset verbose=true "strategy_returns tests" begin
    @testset "single strategy_returns tests" begin
       @test true 
    end

    @testset "vector/ multi strategy_returns tests" begin
       @test true 
    end
end
end # master hedging/ strategy testset 