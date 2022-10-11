using Statistics: std
# "Static ratio hedging"
# delta hedging
# min var hedging

function profit(fin_obj::Option, ratio, number_of_contracts)
   -1 
end

#-------Helper Functions--------#
function find_correlation_coeff(obj_a::Union{Stock, Commodity}, obj_b::Union{Stock, Commodity})
    """
    Pearson correlation
    """
    # Find the returns
    # obj_a_returns = [(obj_a.prices[i + 1] - obj_a.prices[i]) / obj_a.prices[i] for i in 1:(lastindex(obj_a.prices) - 1)]
    # obj_b_returns = [(obj_b.prices[i + 1] - obj_b.prices[i]) / obj_b.prices[i] for i in 1:(lastindex(obj_b.prices) - 1)]
    a_average = sum(obj_a.prices) / lastindex(obj_a.prices)
    b_average = sum(obj_b.prices) / lastindex(obj_b.prices)
    cov = sum((obj_a.prices .- a_average) .* (obj_b.prices .- b_average)) / sqrt(sum((obj_a.prices .- a_average) .^ 2)  * sum((obj_b.prices .- b_average) .^ 2))
    return cov
end

function find_correlation_coeff(obj_a::Union{Stock, Commodity}, obj_b::Option)
    find_correlation_coeff(obj_a, obj_b.widget)
end