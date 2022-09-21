using Bruno
using CSV
using DataFrames

df = CSV.read("./examples/AAPL.csv", DataFrame)
prices = df[!, "Adj Close"]

kwargs = (prices=prices, name="APPL")
widget = Stock(;kwargs...)

list_of_widgets = factory(widget, Stationary(), 5)

a_fin_inst = EuroCallOption(list_of_widgets[1])

x = price(a_fin_inst, BinomialTree, 3, .05, 140, 0)

print(x)
# for i in list_of_widgets
#     println(i.volatility)
# end

