from time import process_time
from julia import Main

Main.include("src/Instruments/Instruments.jl")
Main.include("src/DataGeneration/DataGeneration.jl")

an_obj = Main.Instruments.Stock([1, 2, 3, 4, 5, 6, 7, 8], "AAPL")  # create a julia struct

print(an_obj.name)
print(an_obj.volatility)

an_obj = Main.Instruments.Stock([12, 11, 14, 20, 12, 11, 20], "AAPL")  # recreate julia struct with new prices

print(an_obj.name)
print(an_obj.volatility)

list_of_widgets = Main.DataGeneration.factory(an_obj, Main.DataGeneration.Stationary, 1000)

val = 0
for stock in list_of_widgets:
    val += stock.volatility

print(val / len(list_of_widgets))