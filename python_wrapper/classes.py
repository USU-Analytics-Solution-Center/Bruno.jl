from julia import Main
Main.include("src/Instruments/Instruments.jl")

class Stock:
    def __init__(self, prices, name, volatility=None) -> None:
        # make the julia type object
        if volatility is None:
            self.__jlObg__ = Main.Instruments.Stock(prices, name)
        else:
            self.__jlObg__ = Main.Instruments.Stock(prices, name, volatility)

        self.prices = prices
        self.name = name
        self.volatility = self.__jlObg__.volatility

    def makeStock(self, prices, name, volatility=None):
        self = Stock(prices, name, volatility)  # have to create a new "Stock" julia objs not mutable
        return self

    def set_prices(self, prices):
        return self.makeStock(prices, self.name)

    def get_jl_object(self):
        return self.__jlObg__

    def __str__(self) -> str:
        return "Type Stock\n\tName = " + self.name + "\n\tvolatility = " + str(self.volatility)