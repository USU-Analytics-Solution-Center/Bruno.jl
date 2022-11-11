import InteractiveUtils


@testset "Widget factory" begin
    # Create a data set. The data itself doesnt matter that should be tested in data gen test
    ar1 = [100.0]
    for _ = 1:100
        push!(ar1, 0.99 * (ar1[end] + rand(Normal())))
    end
    widget_subs = InteractiveUtils.subtypes(Widget)
    boot_subs = InteractiveUtils.subtypes(TSBootMethod)
    kwargs = Dict(:prices => ar1, :name => "Example")

    for widget_type in widget_subs
        for boot_type in boot_subs
            widget = widget_type(; kwargs...)

            list_of_widgets = factory(widget, boot_type, 5)
            @test length(list_of_widgets) == 5  # test we got the ammount of widgets requested

            fields = [p for p in fieldnames(typeof(list_of_widgets[1]))]  # get the first item from list of widgets as all others will be indeticale
            iter = Dict(fields .=> getfield.(Ref(list_of_widgets[1]), fields))
            @test length(findall(Base.isempty, iter)) == 0  # Test all fields in each widget have been filled in

            @test length(list_of_widgets) == length(unique(list_of_widgets))  # check each new widget is unique
        end
    end
end

@testset "FinancialInstrument factory" begin
    """
    We need to figure out what we are exporting and how gather all known
    fin_instruments to replicate widget factory. For now I'm just
    implementing a single example for bair bones testing.
    """
    a_stock = Stock([100, 103, 105, 110, 113, 105, 98, 94, 110])
    a_fin_inst = EuroCallOption(a_stock, 105)
    list_of_fins = factory(a_fin_inst, Stationary, 5)
    @test length(list_of_fins) == length(unique(list_of_fins))
    @test length(list_of_fins) == 5

    a_fin_inst = AmericanCallOption(a_stock, 105)
    list_of_fins = factory(a_fin_inst, Stationary, 5)
    @test length(list_of_fins) == length(unique(list_of_fins))
    @test length(list_of_fins) == 5
end
