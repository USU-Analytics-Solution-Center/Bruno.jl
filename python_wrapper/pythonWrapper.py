from classes import Stock
from somefunctions import factory
a_stock = Stock([1, 2, 3, 4, 5, 6, 7, 8], "APPL")
print(a_stock)
a_stock.set_prices([12, 11, 14, 20, 12, 11, 20])
print(a_stock)

print(factory(a_stock, 100))