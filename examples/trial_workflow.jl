using Bruno
using CSV
using DataFrames

df = CSV.read("./examples/AAPL.csv", DataFrame)
prices = df[!, "Adj Close"]

widget = Stock(prices, "AAPL", 1, 1)

list_of_widgets = factory(widget, Stationary(), 5)

println("Original prices")
println(widget.prices)
println(widget.volatility)
println("bootstrapped prices")
println(list_of_widgets.prices)
println(list_of_widgets.volatility)


