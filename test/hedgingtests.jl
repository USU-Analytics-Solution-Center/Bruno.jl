import Bruno.BackTest: buy, sell, update_obj, unwind
using Logging

@testset verbose=true "Hedging and strategy tests" begin
    
@testset "buy function tests" begin
    @testset "buy without transaction costs" begin
        test_stock = Stock(41.0; name = "test", volatility = 0.3)  
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
        test_stock = Stock(41.0; name = "test", volatility = 0.3)  
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
        test_stock = Stock(41.0; name = "test", volatility = 0.3)  
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
        test_stock = Stock(41.0; name = "test", volatility = 0.3)  
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
        test_stock = Stock(41.0; name = "test", volatility = 0.3)  
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
        test_stock = Stock(41.0; name = "test", volatility = 0.3)  
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
        widget_dict = Dict("stock" => test_stock, "stock2" => test_stock2)
        future_prices = Dict("stock" => [1,2,3], "stock2" => [4,5,6])
        holdings = Dict("cash" => 0, "stock" => 1, "stock2" => 2, "call" => 1, "put" => 1, "call2" => 1, "put2" => 1)
        
        new_obj_arr, new_widget_dict = update_obj(
            obj_array, 
            widget_dict, 
            Naked, 
            BlackScholes, 
            holdings, 
            future_prices, 
            10,
            252, 
            1
        )

        # test widgets
        @test new_widget_dict["stock"].prices == [97, 90, 83, 83, 88, 88, 89, 97, 100, 1]
        @test new_widget_dict["stock2"].prices == [61, 70, 55, 65, 63, 57, 55, 53, 68, 4]
        @test isapprox(new_widget_dict["stock"].volatility, 23.008, atol=.01) 
        @test isapprox(new_widget_dict["stock2"].volatility, 14.378, atol=.01) 
        @test new_widget_dict["stock"].name == "stock"
        @test new_widget_dict["stock2"].name == "stock2"

        #test obj array
        @test isapprox(new_obj_arr[1].maturity , 0.496, atol=.01)
        @test new_obj_arr[1].strike_price == 110
        @test new_obj_arr[1].widget == new_widget_dict["stock"]
        @test new_obj_arr[1].label == "call"
        @test new_obj_arr[1].risk_free_rate == .02
        @test isapprox(new_obj_arr[2].maturity , 0.496, atol=.01)
        @test new_obj_arr[2].strike_price == 110
        @test new_obj_arr[2].widget == new_widget_dict["stock"]
        @test new_obj_arr[2].label == "put"
        @test new_obj_arr[2].risk_free_rate == .02
        @test isapprox(new_obj_arr[3].maturity , 0.996, atol=.01)
        @test new_obj_arr[3].strike_price == 70
        @test new_obj_arr[3].widget == new_widget_dict["stock2"]
        @test new_obj_arr[3].label == "call2"
        @test new_obj_arr[3].risk_free_rate == .02

        # test warning for expiring object 
        @test_logs (:warn, "put2 has expired, it will not be able to be bought or sold") update_obj(
            obj_array2, 
            widget_dict, 
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
            widget_dict, 
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
   @testset "single fininst method" begin
        test_stock = Stock(; prices=[99, 97, 90, 83, 83, 88, 88, 89, 97, 100], name="stock", timesteps_per_period=252)
        test_call = EuroCallOption(test_stock, 110; maturity=.5, label="call", risk_free_rate=.02)
        holdings = Dict{String, AbstractFloat}(
            "cash" => 0,
            "stock" => 2,
            "call" => -1
        )

        holdings = unwind(test_call, BlackScholes, holdings)
        @test holdings["stock"] == 0
        @test holdings["call"] == 0
        @test isapprox(holdings["cash"], 180.1648, atol=.01)
   end

   @testset "vector fininst method" begin
        test_stock = Stock(; prices=[99, 97, 90, 83, 83, 88, 88, 89, 97, 100], name="stock", timesteps_per_period=252)
        test_stock2 = Stock(; prices=[66, 61, 70, 55, 65, 63, 57, 55, 53, 68], name="stock2", timesteps_per_period=252)
        test_stock3 = Stock(; prices=[66, 61, 70, 55, 65, 63, 57, 55, 53, 68], name="stock3", timesteps_per_period=252)
        test_call = EuroCallOption(test_stock, 110; maturity=.5, label="call", risk_free_rate=.02)
        test_put = EuroPutOption(test_stock, 110; maturity=.5, label="put", risk_free_rate=.02)
        test_call2 = EuroCallOption(test_stock2, 70; maturity=1, label="call2", risk_free_rate=.02)
        test_put2 = EuroPutOption(test_stock2, 70; maturity=0.001, label="put2", risk_free_rate=.02)
        
        obj_array = [test_call, test_put, test_call2] # doesn't have test_put2
        widget_dict = Dict("stock" => test_stock, "stock2" => test_stock2) # doesnt' have stock3
        holdings = Dict{String, AbstractFloat}(
            "cash" => 0,
            "stock" => 1, 
            "stock2" => -2, 
            "stock3" => 500,
            "call" => 1, 
            "call2" => -1, 
            "put" => 1, 
            "put2" => 1
        )

        unwind(obj_array, widget_dict, BlackScholes, holdings) 
        for fin_inst in obj_array
            @test holdings["$(fin_inst.label)"] == 0
        end
        for (name, widget) in widget_dict
            @test holdings["$(widget.name)"] == 0
        end
        @test isapprox(holdings["cash"], -38.1598, atol=.01)

        # test it didn't unwind fin instruments not in the arrays
        @test holdings["stock3"] == 500
        @test holdings["put2"] == 1
   end 
end

@testset verbose=true "strategy_returns tests" begin
    @testset "single strategy_returns tests" begin
        test_stock = Stock(; prices=[99, 97, 90, 83, 83, 88, 88, 89, 97, 100], name="stock", timesteps_per_period=252)
        test_call = EuroCallOption(test_stock, 110; maturity=.5, label="call", risk_free_rate=.02)
        future_prices = [100, 104, 109, 105, 108, 108, 101, 101, 104, 110]

        # with default values
        test_ret, ts_holdings, obj = strategy_returns(
            test_call, 
            BlackScholes,
            Naked,
            future_prices,
            10,
            252;
            transaction_cost = 0.0
        )

        # test if funciton is returning correct values
        @test isapprox(test_ret, -1.2905, atol=.01)
        @test ts_holdings["call"] == [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0]
        @test ts_holdings["stock"] == [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        @test obj.widget.prices == future_prices
        
        # test that the original data got stomped on
        @test test_stock.prices == [99, 97, 90, 83, 83, 88, 88, 89, 97, 100]

        # test it works for starting cash/ holdings 
        test_ret, ts_holdings, obj = strategy_returns(
            test_call, 
            BlackScholes,
            Naked,
            future_prices,
            10,
            252, 
            10, 
            2, 
            3;
            transaction_cost = 0.0
        )

        @test isapprox(test_ret, 26.128, atol=.01)
        @test ts_holdings["call"] == [2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0]
        @test ts_holdings["stock"] == [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0]
 
        # test with interest rates
        test_ret, ts_holdings, obj = strategy_returns(
            test_call, 
            BlackScholes,
            Naked,
            future_prices,
            10,
            252, 
            10, 
            0, 
            0,
            .08;
            transaction_cost = 0.0
        )
         
        @test isapprox(test_ret, -1.322, atol=.01)
        
        test_ret, ts_holdings, obj = strategy_returns(
            test_call, 
            BlackScholes,
            Naked,
            future_prices,
            10,
            252, 
            30, 
            0, 
            0,
            0,
            .08;
            transaction_cost = 0.0
        )
        @test isapprox(test_ret, -1.258, atol=.01)

        # test that it works for user defining their own strategy
        primitive type TestStrategy <: Hedging 8 end

        function Bruno.strategy(
            fin_obj::FinancialInstrument,
            pricing_model, 
            strategy_mode::Type{TestStrategy},
            holdings, 
            step;
            kwargs...
        )
            if step == 1
                buy(fin_obj, 2, holdings, pricing_model)
            end

            if step == 4
                sell(fin_obj.widget, 2.5, holdings, pricing_model)
            end

            return holdings
        end

        test_ret, ts_holdings, obj = strategy_returns(
            test_call, 
            BlackScholes,
            TestStrategy,
            future_prices,
            10,
            252;
            transaction_cost = 0.0
        )

        @test ts_holdings["call"] == [0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0]
        @test ts_holdings["stock"] == [0, 0, 0, 0, -2.5, -2.5, -2.5, -2.5, -2.5, -2.5, -2.5, 0]
        @test isapprox(ts_holdings["cash"][2], -39.6704, atol=.01)
        @test isapprox(ts_holdings["cash"][5], 232.8296, atol=.01)

        # test strategy_returns limits (checks)
        # not enough data in future_prices
        @test_throws ErrorException strategy_returns(
            test_call, 
            BlackScholes,
            TestStrategy,
            future_prices,
            11,
            252;
            transaction_cost = 0.0
        )

    end

    @testset "vector/ multi strategy_returns tests" begin
        test_stock = Stock(; prices=[99, 97, 90, 83, 83, 88, 88, 89, 97, 100], name="stock", timesteps_per_period=252)
        test_stock2 = Stock(; prices=[66, 61, 70, 55, 65, 63, 57, 55, 53, 68], name="stock2", timesteps_per_period=252)
        test_call = EuroCallOption(test_stock, 110; maturity=.5, label="call", risk_free_rate=.02)
        test_call2 = EuroCallOption(test_stock2, 70; maturity=1, label="call2", risk_free_rate=.02)
        future_prices = Dict(
            "stock" => [100, 104, 109, 105, 108, 108, 101, 101, 104, 110],
            "stock2" => [67, 74, 73, 67, 67, 75, 69, 71, 69, 70]
        )
        objs = [test_call, test_call2]
        fin_obj_count = Dict("call" => 1.0, "call2" => 2)
        widget_count = Dict("stock" => 2.0, "stock2" => 3)

        test_ret, ts_holdings, obj_array = strategy_returns(
            objs, 
            BlackScholes,
            Naked,
            future_prices,
            10,
            252,
            0,
            fin_obj_count,
            widget_count
        )

        @test ts_holdings["call"] == [1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0]
        @test ts_holdings["call2"] == [2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0]

        @test isapprox(ts_holdings["cash"][2], -70.571, atol=.01)
        @test isapprox(test_ret, -45.643, atol=.01)

        # test multi strat returns checks
        # check negative timesteps_per_period
        @test_throws ErrorException test_ret, ts_holdings, obj_array = strategy_returns(
            objs, 
            BlackScholes,
            Naked,
            future_prices,
            10,
            -252,
            0,
            fin_obj_count,
            widget_count
        )

        #check negative n_timesteps
        @test_throws ErrorException test_ret, ts_holdings, obj_array = strategy_returns(
            objs, 
            BlackScholes,
            Naked,
            future_prices,
            -10,
            252,
            0,
            fin_obj_count,
            widget_count
        )
        future_prices = Dict(
            "stock" => [100, 104, 109, 105, 108, 101, 101, 104, 110],
            "stock2" => [67, 74, 73, 67, 67, 75, 69, 71, 69, 70]
        )   
        @test_throws ErrorException test_ret, ts_holdings, obj_array = strategy_returns(
            objs, 
            BlackScholes,
            Naked,
            future_prices,
            10,
            252,
            0,
            fin_obj_count,
            widget_count
        )
        future_prices = Dict(
            "not_a_key" => [100, 104, 109, 105, 108, 101, 101, 104, 110],
            "stock2" => [67, 74, 73, 67, 67, 75, 69, 71, 69, 70]
        )   
        @test_throws ErrorException test_ret, ts_holdings, obj_array = strategy_returns(
            objs, 
            BlackScholes,
            Naked,
            future_prices,
            10,
            252,
            0,
            fin_obj_count,
            widget_count
        )
    end
end
end # master hedging/ strategy testset 