using Bruno
using CSV
using DataFrames

df = CSV.read("AAPL.csv", DataFrame)
prices = df[!, "Adj Close"]



