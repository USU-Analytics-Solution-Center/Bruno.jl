### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ 2afcbb6d-b462-4146-bda4-df878a6a34e4
import Pkg

# ╔═╡ 8f2769a3-447f-41b8-8cdd-28173f4b5750
Pkg.add("Plots");

# ╔═╡ 4b13d507-04f3-482c-921b-a48bb0f26269
Pkg.add("Dates");

# ╔═╡ 567187df-ae30-4c96-b4eb-9392e0a8c0af
Pkg.add("Distributions")

# ╔═╡ a7f23bfa-5a3e-4aa4-b124-7705bc3e804f
using CSV, Plots, DataFrames, Dates, Statistics, Distributions

# ╔═╡ 50fa0f8d-bbc6-494a-b92c-eb8f24b93beb
using Bruno

# ╔═╡ 1eaad207-be7e-4ad7-9677-fb5cd46d2739
md"""Random code to get julia and Bruno running in environment"""

# ╔═╡ 9fa13ebe-c68f-4d7a-bed5-4e985ce14731
md"""Loading in Apple stock price data:"""

# ╔═╡ a35957ee-ef4b-450b-8075-a0b8b53dbcf0
df = CSV.read("./examples/AAPL.csv", DataFrame);

# ╔═╡ 6741c1c7-71cc-4e60-8c84-eb403750166c
years = groupby(transform(df, :Date => x->year.(x)),:Date_function);

# ╔═╡ 591732c6-daa2-476d-b375-12424e23967b
historical_data = vcat(years[4],years[5], cols = :union);

# ╔═╡ 1fcab2a1-878d-49c9-b66c-a05e1637f201
combined_prices = vcat(years[6], cols = :union);

# ╔═╡ ae82b8d0-55c9-4ea9-851d-e1453ca384ef
future_prices = combined_prices[!, "Adj Close"]

# ╔═╡ 9bd438c6-aab3-43d3-8903-9f6edce33eb1
md"""Creating the Stock and EuroCallOption and EuroPutOption structs to be used in the strategies"""

# ╔═╡ 032c8e45-9847-48fc-9e86-5ac3f29cb7b4
apple_stock = Stock(;prices=historical_data[!, "Adj Close"], name="AAPL", volatility=(get_volatility(historical_data[!, "Adj Close"]) / sqrt(2)))

# ╔═╡ d5e9e3d8-dc63-426e-a92b-b675268142d7
appl_call = EuroCallOption(apple_stock, apple_stock.prices[end]; maturity=1, risk_free_rate=.01)

# ╔═╡ 3a546df8-53c1-4538-be3a-342df1e80364
price!(appl_call, BlackScholes)

# ╔═╡ c255b332-8136-4b2a-b9a6-20a635f27d02
plot(1:length(historical_data[!, "Adj Close"]), historical_data[!, "Adj Close"], label="Apple 2020-2021")

# ╔═╡ a8bafa41-c32e-404c-89f4-07aa115df858
plot(1:length(future_prices), future_prices, label="Apple stock 2022")

# ╔═╡ cae9a3d6-16ed-45e7-9efb-f878beffb02b
md"""# Strategy: Delta-hedging by going long stocks"""

# ╔═╡ 0c54c8af-6e44-49b2-90dc-c068192168fa
primitive type MMDeltaHedge <: Bruno.BackTest.Hedging 8 end

# ╔═╡ 7cf4f7f2-94ef-49ff-9fc4-fdbe0e8217e7
function Bruno.BackTest.strategy(fin_obj::CallOption, pricing_model, strategy_mode::Type{MMDeltaHedge}, holdings, step; kwargs...)
	if step == 1
		Bruno.BackTest.sell(fin_obj, 1, holdings, pricing_model, kwargs[:transaction_cost])
	end
	if (step - 1) % kwargs[:steps_between] == 0
        delta = cdf(Normal(), (log(fin_obj.widget.prices[end] / fin_obj.strike_price) + (fin_obj.risk_free_rate + (fin_obj.widget.volatility ^ 2 / 2)) * fin_obj.maturity) / (fin_obj.widget.volatility * sqrt(fin_obj.maturity)))
        holdings["delta"] = -delta
        change = delta - holdings["widget_count"]  # new - old = Change
        if change > 0  # if delta increased we want to increase the hedge
            Bruno.BackTest.buy(fin_obj.widget, change, holdings, pricing_model, 0)
        else  # if delta decreased we want to lessen the hedge 
            Bruno.BackTest.sell(fin_obj.widget, -change, holdings, pricing_model, 0)  # assuming no transaction cost for widgets. Note we flip the sign here for ease in buy
        end
    end

    return holdings
end

# ╔═╡ 3a36182a-a2bc-4bbd-a31b-eed651b961a7
md"""# Delta-hedging with "daily" rebalancing"""

# ╔═╡ e6a900fc-3490-4446-bf0f-32c53fc5f64e
kwargs = Dict(:steps_between => 1)

# ╔═╡ da3f9f17-bbea-4de5-abd4-9daced3e0663
q_call_cash, q_call_holdings, q_call_after = strategy_returns(appl_call, BlackScholes, MMDeltaHedge, future_prices, length(future_prices), 252; transaction_cost=1, kwargs...)

# ╔═╡ 36ef0bee-3469-4b7e-9724-007a0fa25ee5
plot(1:length(q_call_holdings["premium"]), q_call_holdings["premium"], label="premium")

# ╔═╡ 813f9008-abef-428b-8459-3849367e4949
plot(1:length(q_call_holdings["delta"]), q_call_holdings["delta"], label="delta")

# ╔═╡ d8c8d4a6-edac-40b1-a5b1-9371c6391376
plot(1:length(q_call_holdings["widget_count"]), q_call_holdings["widget_count"], label="stock count")

# ╔═╡ d19a2fcd-6e9f-4999-b142-4727b23073db
plot(1:length(q_call_holdings["cash"]), q_call_holdings["cash"], label = "cash")

# ╔═╡ 601bea2d-0863-4387-8b66-4e916c030e16
md"""# Strategy: Delta-hedging with "weekly" rebalancing"""

# ╔═╡ f2621f40-fb8b-42e6-8d83-42164434369b
w_call_cash, w_call_holdings, w_call_after = strategy_returns(appl_call, BlackScholes, MMDeltaHedge, future_prices, length(future_prices), 252; transaction_cost=0.65, steps_between=5)

# ╔═╡ 239d3bf5-0eab-4e7c-8f1d-a50d9c826160
plot(1:length(w_call_holdings["delta"]), w_call_holdings["delta"], label= "delta")

# ╔═╡ dc65119f-7f3c-42e0-853e-f0b153d83356
plot(1:length(w_call_holdings["widget_count"]), w_call_holdings["widget_count"], label="stock count")

# ╔═╡ 0d3adcc2-3c42-4c5f-a9fd-86985f0b1364
plot(1:length(w_call_holdings["cash"]), w_call_holdings["cash"], label="cash")

# ╔═╡ 2e9686cd-ffdd-4b72-8a6c-f5bfd54090b9
md"""# Simulation: Logdiffution"""

# ╔═╡ 69d594d9-b170-4f91-bb41-43885363c5c9
logSetup = LogDiffInput(length(future_prices), appl_call.widget.prices[end], appl_call.widget.volatility / sqrt(252), log(1.3) * length(future_prices) / 252)

# ╔═╡ 1eb02eb1-8620-4f38-accf-cc75f88891c6
logData = makedata(logSetup, 1000)

# ╔═╡ 01222cad-cfd1-449b-99a2-882fd37f34a7
plot(1:length(logData[:,1]), logData[:,1:10], title= "Price path simulation", legend=false)

# ╔═╡ 9fdd2f9c-8996-4053-929f-ce5be350fc24
md"""### Saving the simulated dollar returns"""

# ╔═╡ bab1220b-e71c-4461-8e97-09d5917fb322
dollar_returns_daily_hedge = []

# ╔═╡ a1eae53a-dcbc-4e95-8dca-003cce86e38c
for i in 1:1000
	new_values = Array(logData[:,i])
	anOption = EuroCallOption(apple_stock, apple_stock.prices[end]; maturity=1)
	loop_dollar_returns, holdingsX, xy = strategy_returns(appl_call, BlackScholes, MMDeltaHedge, new_values, length(new_values), 252; transaction_cost=0.1, steps_between=1)
	push!(dollar_returns_daily_hedge, loop_dollar_returns)
end

# ╔═╡ 1e9c4ddf-bae9-4ebc-b021-1933b307e06b
begin
	histogram(dollar_returns_daily_hedge)
	plot!([mean(dollar_returns_daily_hedge)], seriestype="vline", linewidth=10, legend=false)
end

# ╔═╡ 94860b26-060c-4a4a-98cd-0a963f1d9943
dollary_returns_weekly_hedge=[]

# ╔═╡ 3d30c698-8193-4ab6-b46a-4c2455cabc6c
for i in 1:1000
	new_values = Array(logData[:,i])
	anOption = EuroCallOption(apple_stock, apple_stock.prices[end]; maturity=1)
	loop_dollar_returns, holdingsX, xy = strategy_returns(appl_call, BlackScholes, MMDeltaHedge, new_values, length(new_values), 252; transaction_cost=0.1, steps_between=5)
	push!(dollary_returns_weekly_hedge, loop_dollar_returns)
end

# ╔═╡ 51d8afce-7755-4818-bb3d-8bb57a3adc70
begin
	histogram(dollary_returns_weekly_hedge)
	plot!([mean(dollary_returns_weekly_hedge)], seriestype="vline", linewidth=10, legend=false)
end

# ╔═╡ a0874914-fcc5-4273-82cd-0d52aa3956d5
mean(dollary_returns_weekly_hedge)

# ╔═╡ 0a9ad960-1965-489d-9ab1-45147d1c78d9


# ╔═╡ 0f0ad149-7114-4530-a564-7ccfb2b732a1
md"## Bootstrap simulation"

# ╔═╡ fe716be7-af81-4e05-af36-895cb525d823
apple_stock.prices

# ╔═╡ 3de71c79-8621-403d-9711-e6fb767a0079
historic_returns = [(apple_stock.prices[i+1] - apple_stock.prices[i])/apple_stock.prices[i] for i in 1:length(apple_stock.prices)-1]

# ╔═╡ 6af36019-41ad-432d-9531-83c11d2ef672
boot_setup = BootstrapInput(historic_returns, Stationary; n=length(future_prices))

# ╔═╡ bb227e51-9e29-461b-8f06-67c852b9ac7d
boot_returns = makedata(boot_setup, 10000)

# ╔═╡ 0b5e0a68-922d-4ad2-8e79-f7c74092a352
begin 
	boot_hedge_returns = []
	for i in 1:10000
		new_prices = [apple_stock.prices[end]]
		for ret in Array(boot_returns[:,i])
			push!(new_prices, new_prices[end]*(1+ret))
		end
		anOption = EuroCallOption(apple_stock, apple_stock.prices[end]; maturity=1)
		loop_dollar_returns, holdingsX, xy = strategy_returns(appl_call, BlackScholes, MMDeltaHedge, new_prices, length(new_prices), 252; transaction_cost=0.1, steps_between=5)
		push!(boot_hedge_returns, loop_dollar_returns)
	end
end

# ╔═╡ f2d6ed8f-8880-4120-b17f-98978e2e9267
mean(boot_hedge_returns)

# ╔═╡ 6c0d1cec-489e-49d2-9a8c-206da049dd36
std(boot_hedge_returns)

# ╔═╡ 167f6c4b-c9b7-42cc-a2bd-79507511d2c7


# ╔═╡ dff98b65-35c2-400a-8ac1-f87e1d485b02
begin
	histogram(boot_hedge_returns)
	plot!([mean(boot_hedge_returns)], seriestype="vline", linewidth=10, legend=false)
end

# ╔═╡ 1c31abdc-e97f-4cdc-8351-c12ce6878cef
begin 
	day_boot_hedge_returns = []
	for i in 1:10000
		new_prices = [apple_stock.prices[end]]
		for ret in Array(boot_returns[:,i])
			push!(new_prices, new_prices[end]*(1+ret))
		end
		anOption = EuroCallOption(apple_stock, apple_stock.prices[end]; maturity=1)
		loop_dollar_returns, holdingsX, xy = strategy_returns(appl_call, BlackScholes, MMDeltaHedge, new_prices, length(new_prices), 252; transaction_cost=0.1, steps_between=1)
		push!(day_boot_hedge_returns, loop_dollar_returns)
	end
end

# ╔═╡ a8e8c745-7eba-493a-a4f5-f314907cab31
begin
	histogram(day_boot_hedge_returns)
	plot!([mean(day_boot_hedge_returns)], seriestype="vline", linewidth=10, legend=false)
end

# ╔═╡ e4e40a45-2dbc-40ee-aba0-c5da88513341
mean(day_boot_hedge_returns)

# ╔═╡ 52d1d85c-be2e-4b8e-a144-bf80d35bc34f
std(day_boot_hedge_returns)

# ╔═╡ Cell order:
# ╟─1eaad207-be7e-4ad7-9677-fb5cd46d2739
# ╟─2afcbb6d-b462-4146-bda4-df878a6a34e4
# ╠═8f2769a3-447f-41b8-8cdd-28173f4b5750
# ╠═4b13d507-04f3-482c-921b-a48bb0f26269
# ╠═567187df-ae30-4c96-b4eb-9392e0a8c0af
# ╠═a7f23bfa-5a3e-4aa4-b124-7705bc3e804f
# ╠═50fa0f8d-bbc6-494a-b92c-eb8f24b93beb
# ╟─9fa13ebe-c68f-4d7a-bed5-4e985ce14731
# ╠═a35957ee-ef4b-450b-8075-a0b8b53dbcf0
# ╠═6741c1c7-71cc-4e60-8c84-eb403750166c
# ╠═591732c6-daa2-476d-b375-12424e23967b
# ╠═1fcab2a1-878d-49c9-b66c-a05e1637f201
# ╠═ae82b8d0-55c9-4ea9-851d-e1453ca384ef
# ╟─9bd438c6-aab3-43d3-8903-9f6edce33eb1
# ╠═032c8e45-9847-48fc-9e86-5ac3f29cb7b4
# ╠═d5e9e3d8-dc63-426e-a92b-b675268142d7
# ╠═3a546df8-53c1-4538-be3a-342df1e80364
# ╠═c255b332-8136-4b2a-b9a6-20a635f27d02
# ╠═a8bafa41-c32e-404c-89f4-07aa115df858
# ╟─cae9a3d6-16ed-45e7-9efb-f878beffb02b
# ╠═0c54c8af-6e44-49b2-90dc-c068192168fa
# ╠═7cf4f7f2-94ef-49ff-9fc4-fdbe0e8217e7
# ╟─3a36182a-a2bc-4bbd-a31b-eed651b961a7
# ╠═e6a900fc-3490-4446-bf0f-32c53fc5f64e
# ╠═da3f9f17-bbea-4de5-abd4-9daced3e0663
# ╠═36ef0bee-3469-4b7e-9724-007a0fa25ee5
# ╠═813f9008-abef-428b-8459-3849367e4949
# ╠═d8c8d4a6-edac-40b1-a5b1-9371c6391376
# ╠═d19a2fcd-6e9f-4999-b142-4727b23073db
# ╟─601bea2d-0863-4387-8b66-4e916c030e16
# ╠═f2621f40-fb8b-42e6-8d83-42164434369b
# ╠═239d3bf5-0eab-4e7c-8f1d-a50d9c826160
# ╠═dc65119f-7f3c-42e0-853e-f0b153d83356
# ╠═0d3adcc2-3c42-4c5f-a9fd-86985f0b1364
# ╟─2e9686cd-ffdd-4b72-8a6c-f5bfd54090b9
# ╠═69d594d9-b170-4f91-bb41-43885363c5c9
# ╠═1eb02eb1-8620-4f38-accf-cc75f88891c6
# ╠═01222cad-cfd1-449b-99a2-882fd37f34a7
# ╟─9fdd2f9c-8996-4053-929f-ce5be350fc24
# ╠═bab1220b-e71c-4461-8e97-09d5917fb322
# ╠═a1eae53a-dcbc-4e95-8dca-003cce86e38c
# ╠═1e9c4ddf-bae9-4ebc-b021-1933b307e06b
# ╠═94860b26-060c-4a4a-98cd-0a963f1d9943
# ╠═3d30c698-8193-4ab6-b46a-4c2455cabc6c
# ╠═51d8afce-7755-4818-bb3d-8bb57a3adc70
# ╠═a0874914-fcc5-4273-82cd-0d52aa3956d5
# ╠═0a9ad960-1965-489d-9ab1-45147d1c78d9
# ╠═0f0ad149-7114-4530-a564-7ccfb2b732a1
# ╠═fe716be7-af81-4e05-af36-895cb525d823
# ╠═3de71c79-8621-403d-9711-e6fb767a0079
# ╠═6af36019-41ad-432d-9531-83c11d2ef672
# ╠═bb227e51-9e29-461b-8f06-67c852b9ac7d
# ╠═0b5e0a68-922d-4ad2-8e79-f7c74092a352
# ╠═f2d6ed8f-8880-4120-b17f-98978e2e9267
# ╠═6c0d1cec-489e-49d2-9a8c-206da049dd36
# ╠═167f6c4b-c9b7-42cc-a2bd-79507511d2c7
# ╠═dff98b65-35c2-400a-8ac1-f87e1d485b02
# ╠═1c31abdc-e97f-4cdc-8351-c12ce6878cef
# ╠═a8e8c745-7eba-493a-a4f5-f314907cab31
# ╠═e4e40a45-2dbc-40ee-aba0-c5da88513341
# ╠═52d1d85c-be2e-4b8e-a144-bf80d35bc34f
