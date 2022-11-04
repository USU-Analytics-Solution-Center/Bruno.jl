from classes import Stock
from somefunctions import factory, Stationary
a_stock = Stock([1, 2, 3, 4, 5, 6, 7, 8], "APPL")
print(a_stock)
a_stock = a_stock.set_prices([12, 11, 14, 20, 12, 11, 20])
print(a_stock)
list_of_stocks = factory(a_stock, Stationary, 1000)

val = 0
for stock in list_of_stocks:
    val += stock.volatility

print(val / len(list_of_stocks))