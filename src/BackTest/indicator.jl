function profit(widget::Stock, _::Type{MeanReversion}, daysout)
    # pretend we are generating new data or using historic data what ever we decide...
    # pretend we actually do a mean reversion strategy here and get a retrun of $21
    return 21
end

function profit(widget::Stock, _::Type{BollingerBands}, daysout)
    return -1
end

function profit(widget_a::Stock, widget_b::Stock, _::Type{PairsTrading}, daysout)
    return -1
end
