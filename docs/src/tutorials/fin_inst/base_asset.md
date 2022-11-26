# Base Assets (Widgets)

## Overview 
[Widgets](@ref Type_system) are base (or underlying) assets for a FinancialInstrument, they can also be used by themselves. Examples include the Stock, Bond, and Commodity structs. 

## [Creating a Widget](@id widget_tutorial)
The following example is how to create a random dataset representing historical prices and creat a Stock widget using those prices. 
``` 
# creating a random 'dataset' of 15 simulated prices
historical_prices = rand(50:70, 15)

# creates a Stock widget assuming hisorical prices are daily prices
a_widget = Stock(;prices=historical_prices, name="my_widget", timesteps_per_period=252)
```

## Interacting with a Widget
```
historical_prices = [1, 2, 3, 4, 5]

# creates a Stock widget
a_widget = Stock(;prices=historical_prices, name="my_widget", timesteps_per_period=252)

# price the Stock widget
stock_price = price!(a_widget, StockPrice)
```