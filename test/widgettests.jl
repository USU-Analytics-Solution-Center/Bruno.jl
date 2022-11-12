import InteractiveUtils

@testset verbose = true "Widget constructor tests" begin

    @testset verbose = true "ordered argumentes creation tests" begin
        @testset "Stock Creation" begin
            # Test the stock widget creation
            # Test ordered argumentes when only price given
            a_widget = Stock([1, 2, 3, 4, 5, 4, 3, 2, 1])
            @test isapprox(a_widget.volatility, 1.322, atol = 0.001)
            @test a_widget.name == ""
            @test a_widget.prices == [1, 2, 3, 4, 5, 4, 3, 2, 1]
            @test a_widget.timesteps_per_period == 9 # tests defualt value

            # Test ordered argumentes when name and timesteps not given
            a_widget = Stock(prices = [1, 2, 3, 4, 5, 4, 3, 2, 1], volatility = 0.05)
            @test a_widget.volatility == 0.05
            @test a_widget.name == ""
            @test a_widget.prices == [1, 2, 3, 4, 5, 4, 3, 2, 1]
            @test a_widget.timesteps_per_period == 9 # tests defualt value

            # Test ordered argumentes when all given
            a_widget = Stock(
                prices = [1, 2, 3, 4, 5, 4, 3, 2, 1],
                volatility = 0.05,
                name = "Example",
                timesteps_per_period = 9
            )
            @test a_widget.volatility == 0.05
            @test a_widget.name == "Example"
            @test a_widget.prices == [1, 2, 3, 4, 5, 4, 3, 2, 1]
            @test a_widget.timesteps_per_period == 9

            # Test strickly ordered inputs
            a_widget = Stock(
                [1, 2, 3, 4, 5, 4, 3, 2, 1], 
                "Example", 
                9, 
                0.05
            )
            @test a_widget.volatility == 0.05
            @test a_widget.name == "Example"
            @test a_widget.prices == [1, 2, 3, 4, 5, 4, 3, 2, 1]
            @test a_widget.timesteps_per_period == 9

        end

        @testset "Commodities Creation" begin
            # Test the Commodity widget creation

            # Test ordered argumentes when only price given
            a_widget = Commodity([1, 2, 3, 4, 5, 4, 3, 2, 1])
            @test isapprox(a_widget.volatility, 1.322, atol = 0.001)
            @test a_widget.name == ""
            @test a_widget.prices == [1, 2, 3, 4, 5, 4, 3, 2, 1]
            @test a_widget.timesteps_per_period == 9

            # Test ordered argumentes when name not given
            a_widget = Commodity(prices = [1, 2, 3, 4, 5, 4, 3, 2, 1], volatility = 0.05)
            @test a_widget.volatility == 0.05
            @test a_widget.name == ""
            @test a_widget.prices == [1, 2, 3, 4, 5, 4, 3, 2, 1]
            @test a_widget.timesteps_per_period == 9

            # Test ordered argumentes when all given
            a_widget = Commodity(
                prices = [1, 2, 3, 4, 5, 4, 3, 2, 1],
                volatility = 0.05,
                name = "Example",
                timesteps_per_period = 9
            )
            @test a_widget.volatility == 0.05
            @test a_widget.name == "Example"
            @test a_widget.prices == [1, 2, 3, 4, 5, 4, 3, 2, 1]
            @test a_widget.timesteps_per_period == 9

        end

        @testset "Bonds Creation" begin
            # Test the Bond widget creation

            # Test ordered argumentes when only price given
            a_widget = Bond([1, 2, 3, 4, 5, 4, 3, 2, 1])
            @test a_widget.prices == [1, 2, 3, 4, 5, 4, 3, 2, 1]
            @test a_widget.name == ""
            @test a_widget.time_mat == 1
            @test a_widget.coupon_rate == 0.03
            # Test ordered argumentes when name not given
            a_widget = Bond(prices = [1, 2, 3, 4, 5, 4, 3, 2, 1], time_mat = 2)
            @test a_widget.prices == [1, 2, 3, 4, 5, 4, 3, 2, 1]
            @test a_widget.name == ""
            @test a_widget.time_mat == 2
            @test a_widget.coupon_rate == 0.03

            # Test ordered argumentes when all given
            a_widget = Bond(
                prices = [1, 2, 3, 4, 5, 4, 3, 2, 1],
                time_mat = 2,
                name = "Example",
                coupon_rate = 0.5,
            )
            @test a_widget.prices == [1, 2, 3, 4, 5, 4, 3, 2, 1]
            @test a_widget.name == "Example"
            @test a_widget.time_mat == 2
            @test a_widget.coupon_rate == 0.5

        end

    end

    @testset "Single price creation $widget" for widget in [Stock, Commodity]

        a_widget = widget(10; volatility = 0.3)
        @test a_widget.prices == [10]
        @test a_widget.volatility == 0.3
        @test a_widget.name == "" 
        @test a_widget.timesteps_per_period == 0
    end

    widget_subs = InteractiveUtils.subtypes(Widget)
    @testset "Kwargs creation tests $widget" for widget in widget_subs

        # Test kwarg creation when only prices is given
        kwargs = Dict(:prices => [1, 2, 3, 4, 5, 4, 3, 2, 1])
        a_widget = widget(; kwargs...)
        fields = [p for p in fieldnames(typeof(a_widget))]
        iter = Dict(fields .=> getfield.(Ref(a_widget), fields))
        @test length(findall(Base.isempty, iter)) == 1  # Test all fields in each widget have been filled in. Name defaults to "" and counts as isempty

        # Test kwarg creation when price and name given
        kwargs = Dict(:prices => [1, 2, 3, 4, 5, 4, 3, 2, 1], :name => "Example")
        a_widget = widget(; kwargs...)
        fields = [p for p in fieldnames(typeof(a_widget))]
        iter = Dict(fields .=> getfield.(Ref(a_widget), fields))
        @test length(findall(Base.isempty, iter)) == 0

        # Test kwarg creation when obstructing feilds provided
        kwargs = Dict(
            :prices => [1, 2, 3, 4, 5, 4, 3, 2, 1],
            :name => "Example",
            :time_mat => 1,
            :volatility => 0.5,
            :foo => "bar",
        )
        a_widget = widget(; kwargs...)
        fields = [p for p in fieldnames(typeof(a_widget))]
        iter = Dict(fields .=> getfield.(Ref(a_widget), fields))
        @test length(findall(Base.isempty, iter)) == 0
    end

    @testset "Constructor limits" begin
        widget_subs = InteractiveUtils.subtypes(Widget)
        @testset "Price size for $widget" for widget in widget_subs
            @test_throws ErrorException widget(; prices = AbstractFloat[])
        end

        @testset "Single price errors for $widget" for widget in [Stock, Commodity]
            # using kwargs price > 0
            @test_throws ErrorException widget(; prices = -1)
            # using kwargs must give volatility
            @test_throws ErrorException widget(; prices = 1)
            # using position args price > 0
            @test_throws ErrorException widget(-1, "", 0.03)
            # using position must give volatility
            @test_throws ErrorException widget(1, "")
        end

        @testset "volatility errors for $widget" for widget in [Stock, Commodity]
            @test_throws ErrorException widget(; prices = [1, 2, 3], volatility = -1)
            @test_throws ErrorException widget(; prices = [1, 2, 3], volatility = nothing)
        end

        @testset "timesteps_per_period error for $widget" for widget in [Stock, Commodity]
            @test_throws ErrorException widget(; 
            prices = [1, 2, 3, 4], 
            timesteps_per_period = -1, 
            volatility = .1
        )
        end

        @testset "time_mat error for Bond" begin
            @test_throws ErrorException Bond(; prices = [1, 2, 3], time_mat = 0)
        end

    end
end # master testset for Widget constructors
