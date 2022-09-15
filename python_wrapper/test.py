# Imports and downloads Julia if now already downloaded
# Need to figure out how to dynamucally do this...
# Maybe have an outer python function that the user calls
# and it handels the julia download/ seperate function calls

from time import process_time
from julia import Main
import pandas as pd

print("Loading Julia")
js_start = process_time()
Main.include("src/Instruments/Instruments.jl")
Main.include("src/DataGeneration/DataGeneration.jl")
js_loaded = process_time()
print("loaded Julia in ", js_loaded - js_start)

date_set = pd.read_csv("examples/AAPL.CSV")["Adj Close"].tolist()
an_obj = Main.Instruments.Stock(date_set, "AAPL", -1, 1)
list_of_widgets = Main.DataGeneration.factory(an_obj, Main.DataGeneration.Stationary(), 1)

print(list_of_widgets)