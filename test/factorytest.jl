@testset "Widget factory" begin
    # Create a data set. The data itself doesnt matter that should be tested in data gen test
    ar1 = [100.0]
    for _ in 1:100
        push!(ar1, 0.99 * (ar1[end] + rand(Normal())))
    end
    widget_subs = [Commodity, Stock]
    boot_subs = [CircularBlock, MovingBlock, Stationary]

    for widget_type in widget_subs
        for boot_type in boot_subs
            println("Widget Type: ", widget_type, "\tboot_type: ", boot_type)
            kwargs = (prices=ar1, name="test")
            widget = widget_type(;kwargs...)

            list_of_widgets = factory(widget, boot_type, 5)
            @test length(list_of_widgets) == 5
        end
    end



end

@testset "FinancialInstrument factory" begin

end