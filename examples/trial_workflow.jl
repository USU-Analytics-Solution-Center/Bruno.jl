using Bruno
using CSV
using DataFrames

df = CSV.read("./examples/AAPL.csv", DataFrame)
prices = df[!, "Adj Close"]

widget = Stock(prices, "AAPL", 1, 1)

list_of_widgets = factory(widget, Stationary(), 5)

for i in list_of_widgets
    println(i.volatility)
end

