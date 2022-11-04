from julia import Main
from classes import Stock
Main.include("src/DataGeneration/DataGeneration.jl")

# Bootstrap Methods
Stationary = Main.DataGeneration.Stationary


# Factory Wraper
def factory(obj, method, to_produce):
    list_of_widgets = Main.DataGeneration.factory(obj.get_jl_object(), method, to_produce)
    python_list = [Stock(julia_object.prices, julia_object.name, julia_object.volatility) for julia_object in list_of_widgets]

    return python_list