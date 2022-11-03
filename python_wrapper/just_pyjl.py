from time import process_time
from julia import Main
import pandas as pd



Main.include("src/Instruments/Instruments.jl")
an_obj = Main.Instruments.Stock([1, 2, 3, 4, 5, 6, 7, 8], "AAPL")  # create a julia struct

print(an_obj.name)
print(an_obj.volatility)

an_obj = Main.Instruments.Stock([12, 11, 14, 20, 12, 11, 20], "AAPL")  # recreate julia struct with new prices

print(an_obj.name)
print(an_obj.volatility)