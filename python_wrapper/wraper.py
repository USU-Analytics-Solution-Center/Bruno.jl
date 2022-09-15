from time import process_time
from julia import Main
import pandas as pd

print("Loading Julia")
js_start = process_time()
# Need to inculde julia source code in order whatever order they refrence eachother
Main.include("src/Instruments/Instruments.jl")
Main.include("src/DataGeneration/DataGeneration.jl")
js_loaded = process_time()
print("loaded Julia in ", js_loaded - js_start)

date_set = pd.read_csv("examples/AAPL.CSV")["Adj Close"].tolist()
an_obj = Main.Instruments.Stock(date_set, "AAPL", -1, 1)  # create a julia struct
list_of_widgets = []
for i in range(1000):
    list_of_widgets.append(Main.DataGeneration.factory(an_obj, Main.DataGeneration.Stationary(), 1))

for widget in list_of_widgets:
    print(widget.volatility)