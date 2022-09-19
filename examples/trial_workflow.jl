using Bruno
using CSV
using DataFrames

df = CSV.read("./examples/AAPL.csv", DataFrame)
prices = df[!, "Adj Close"]

kwargs = (prices=prices, name="APPL")
widget = Stock(;kwargs...)

list_of_widgets = factory(widget, Stationary(), 5)

a_fin_inst = CallOption(list_of_widgets[1], 12, Dict("a" => 1, "b" => 2, "c" => 3))

# for i in list_of_widgets
#     println(i.volatility)
# end

