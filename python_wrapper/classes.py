from julia import Main
Main.include("src/Instruments/Instruments.jl")

class Stock:
    def __init__(self, prices, name, volatility=None) -> None:
        # make the julia type object
        if volatility is None:
            self.__stock__ = Main.Instruments.Stock(prices, name)
        else:
            self.__stock__ = Main.Instruments.Stock(prices, name, volatility)

        self.prices = prices
        self.name = name
        self.volatility = self.__stock__.volatility

    def makeStock(self, prices, name, volatility=None):
        return Stock(prices, name, volatility)  # have to create a new "Stock" julia objs not mutable

    def set_prices(self, prices):
        self.__stock__ = self.makeStock(prices, self.name)
        self.prices = prices
        self.volatility = self.__stock__.volatility

    def __str__(self) -> str:
        return "Type Stock\n\tName = " + self.name + "\n\tvolatility = " + str(self.volatility)