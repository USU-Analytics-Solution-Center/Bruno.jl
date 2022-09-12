using Bruno

function main()
    stock = Stock(10, "AAPL", 1)
    option = CallOption(stock, BlackScholes(), 1)

    simulate(option)
end