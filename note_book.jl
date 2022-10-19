### A Pluto.jl notebook ###
# v0.19.13

using Markdown
using InteractiveUtils

# ╔═╡ 2afcbb6d-b462-4146-bda4-df878a6a34e4
import Pkg

# ╔═╡ 8f2769a3-447f-41b8-8cdd-28173f4b5750
Pkg.add("Plots");

# ╔═╡ 4b13d507-04f3-482c-921b-a48bb0f26269
Pkg.add("Dates");

# ╔═╡ c5338429-383e-4311-b740-e5390de4cb09
Pkg.add("Indicators")

# ╔═╡ a7f23bfa-5a3e-4aa4-b124-7705bc3e804f
using CSV, Plots, DataFrames, Dates

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
historical_data = years[1];

# ╔═╡ 1fcab2a1-878d-49c9-b66c-a05e1637f201
combined_prices = vcat(years[2], years[3], years[4], years[5], years[6], cols = :union);

# ╔═╡ ae82b8d0-55c9-4ea9-851d-e1453ca384ef
future_prices = combined_prices[!, "Adj Close"]

# ╔═╡ 9bd438c6-aab3-43d3-8903-9f6edce33eb1
md"""Creating the Stock and EuroCallOption and EuroPutOption structs to be used in the strategies"""

# ╔═╡ 032c8e45-9847-48fc-9e86-5ac3f29cb7b4
apple_stock = Stock(;prices=historical_data[!, "Adj Close"], name="AAPL")

# ╔═╡ 9f5d02f3-5105-4f8b-bc0a-b31be938149c
appl_put = EuroPutOption(apple_stock, apple_stock.prices[end]; maturity=5)

# ╔═╡ d5e9e3d8-dc63-426e-a92b-b675268142d7
appl_call = EuroCallOption(apple_stock, apple_stock.prices[end]; maturity=5)

# ╔═╡ e6a900fc-3490-4446-bf0f-32c53fc5f64e
kwargs = Dict(:steps_between => 91)

# ╔═╡ 3a36182a-a2bc-4bbd-a31b-eed651b961a7
md"""### Running the strategy for a rebalanced delta hedge with quarterly rebalancing"""

# ╔═╡ 5ddc4d13-c484-4a95-8f3b-61c326b9731e
q_put_cash, q_put_holdings, q_put_after = strategy_returns(appl_put, BlackScholes, RebalanceDeltaHedge, future_prices, length(future_prices), 252; transaction_cost=0.65, kwargs...)

# ╔═╡ 947384f4-2549-4033-8c06-8a1e348461df
q_put_cash

# ╔═╡ 0848a031-b32d-4d27-b703-298ca1607d0e
plot(1:length(q_put_holdings["widget_count"]), q_put_holdings["widget_count"])

# ╔═╡ 94866539-4213-450a-8a43-003a178ad60d
plot(1:length(q_put_holdings["fin_obj_count"]), q_put_holdings["fin_obj_count"])

# ╔═╡ 87eae18c-8174-4443-9372-4f0877fedbce
plot(1:length(q_put_holdings["cash"]), q_put_holdings["cash"])

# ╔═╡ 16c22925-6dbb-442a-8681-0f006730c020
plot(1:length(q_put_holdings["delta"]), q_put_holdings["delta"])

# ╔═╡ da3f9f17-bbea-4de5-abd4-9daced3e0663
q_call_cash, q_call_holdings, q_call_after = strategy_returns(appl_call, BlackScholes, RebalanceDeltaHedge, future_prices, length(future_prices), 252; transaction_cost=0.65, kwargs...)

# ╔═╡ bb6a7bd1-c1f1-4897-9745-a21d739c21c8
q_call_cash

# ╔═╡ d8c8d4a6-edac-40b1-a5b1-9371c6391376
plot(1:length(q_call_holdings["widget_count"]), q_call_holdings["widget_count"])

# ╔═╡ d19a2fcd-6e9f-4999-b142-4727b23073db
plot(1:length(q_call_holdings["cash"]), q_call_holdings["cash"])

# ╔═╡ ec2c5122-8382-4011-8281-74d234a7e0c7
plot(1:length(q_call_holdings["delta"]), q_call_holdings["delta"])

# ╔═╡ 601bea2d-0863-4387-8b66-4e916c030e16
md"""### Rebalanced Delta Hedge with weekly rebalancing"""

# ╔═╡ 0eb0ff0e-9644-4cd7-be61-900d223eb88c
w_put_cash, w_put_holdings, w_put_after = strategy_returns(appl_put, BlackScholes, RebalanceDeltaHedge, future_prices, length(future_prices), 252; transaction_cost=0.65, steps_between=5)

# ╔═╡ 055eadf4-8d4d-4177-b764-e30ebedccd8f
w_put_cash

# ╔═╡ b7459187-c9d6-4c14-a2d2-4988a1043d1f
plot(1:length(w_put_holdings["widget_count"]), w_put_holdings["widget_count"])

# ╔═╡ 2b7b7a40-394e-4a15-a7eb-3f46bdc93d7f
plot(1:length(w_put_holdings["cash"]), w_put_holdings["cash"])

# ╔═╡ e9197e73-18ae-4e3a-af8e-b642eff7506d
plot(1:length(w_put_holdings["delta"]), w_put_holdings["delta"])

# ╔═╡ f2621f40-fb8b-42e6-8d83-42164434369b
w_call_cash, w_call_holdings, w_call_after = strategy_returns(appl_call, BlackScholes, RebalanceDeltaHedge, future_prices, length(future_prices), 252; transaction_cost=0.65, steps_between=5)

# ╔═╡ a85c1df8-5eb8-4e00-94ad-9d496d15bfde
w_call_cash

# ╔═╡ dc65119f-7f3c-42e0-853e-f0b153d83356
plot(1:length(w_call_holdings["widget_count"]), w_call_holdings["widget_count"])

# ╔═╡ 0d3adcc2-3c42-4c5f-a9fd-86985f0b1364
plot(1:length(w_call_holdings["cash"]), w_call_holdings["cash"])

# ╔═╡ 239d3bf5-0eab-4e7c-8f1d-a50d9c826160
plot(1:length(w_call_holdings["delta"]), w_call_holdings["delta"])

# ╔═╡ c066178c-470c-4a8e-98b6-5ac3f427ef0b
md"""### Rebalanced Delta Hedge with daily rebalancing"""

# ╔═╡ b8c55aba-edb4-493b-8e8a-2a15e77c48b5
d_put_cash, d_put_holdings, d_put_after = strategy_returns(appl_put, BlackScholes, RebalanceDeltaHedge, future_prices, length(future_prices), 252; transaction_cost=0.65, steps_between=1)

# ╔═╡ 6107da8f-6fab-42f4-b18a-0c82c862969d
d_put_cash

# ╔═╡ 05d79851-ef16-4359-a5ca-56c040ca141b
plot(1:length(d_put_holdings["widget_count"]), d_put_holdings["widget_count"])

# ╔═╡ 7d83955b-909c-4628-bc0d-5a3208cbec6e
plot(1:length(d_put_holdings["cash"]), d_put_holdings["cash"])

# ╔═╡ 09ab1dad-5cc8-441e-bd90-46f62839d07c
plot(1:length(d_put_holdings["delta"]), d_put_holdings["delta"])

# ╔═╡ 4e7fd906-ab06-48ab-b599-b33df1984bea
d_call_cash, d_call_holdings, d_call_after = strategy_returns(appl_call, BlackScholes, RebalanceDeltaHedge, future_prices, length(future_prices), 252; transaction_cost=0.65, steps_between=1)

# ╔═╡ 376b6890-5f6d-4448-bc33-c02d8c66517f
d_call_cash

# ╔═╡ a5349b56-3f7a-45ab-ab1a-372d8e5bb2c7
plot(1:length(d_call_holdings["widget_count"]), d_call_holdings["widget_count"])

# ╔═╡ 2320e500-90aa-429d-9973-d991f9e9445a
plot(1:length(d_call_holdings["cash"]), d_call_holdings["cash"])

# ╔═╡ be636d76-f6b6-46c6-aabe-51ca944dc744
plot(1:length(d_call_holdings["delta"]), d_call_holdings["delta"])

# ╔═╡ ffe721dd-7a74-4b7d-9d82-c9dba69017e8
import Indicators

# ╔═╡ d4766288-6faa-401c-974e-7c09d0d665c0
fast_moving_avg = Indicators.ema(Array(df[!, "Adj Close"]); n=20)

# ╔═╡ d313b6ac-d3f9-4a45-adcb-6a1da2759d07
slow_moving_avg = Indicators.ema(Array(df[!, "Adj Close"]); n=60)

# ╔═╡ ac6bd368-20ac-4665-8522-cf17b88175ee
primitive type StockPriceEMACross 8 end

# ╔═╡ 8c19e038-425e-423a-bdef-f6bf9ab14ada
function strategy(fin_obj::Stock, pricing_model, strategy_mode::Type{StockPriceEMACross}, holdings, step; kwargs...)
	nothing
end

# ╔═╡ e833942a-b45e-42f2-8743-d3da9dc12aa3


# ╔═╡ d57ad250-ad79-41b7-9eca-ecbf2fd08265


# ╔═╡ Cell order:
# ╟─1eaad207-be7e-4ad7-9677-fb5cd46d2739
# ╟─2afcbb6d-b462-4146-bda4-df878a6a34e4
# ╠═8f2769a3-447f-41b8-8cdd-28173f4b5750
# ╠═4b13d507-04f3-482c-921b-a48bb0f26269
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
# ╠═9f5d02f3-5105-4f8b-bc0a-b31be938149c
# ╠═d5e9e3d8-dc63-426e-a92b-b675268142d7
# ╠═e6a900fc-3490-4446-bf0f-32c53fc5f64e
# ╟─3a36182a-a2bc-4bbd-a31b-eed651b961a7
# ╠═5ddc4d13-c484-4a95-8f3b-61c326b9731e
# ╠═947384f4-2549-4033-8c06-8a1e348461df
# ╠═0848a031-b32d-4d27-b703-298ca1607d0e
# ╠═94866539-4213-450a-8a43-003a178ad60d
# ╠═87eae18c-8174-4443-9372-4f0877fedbce
# ╠═16c22925-6dbb-442a-8681-0f006730c020
# ╠═da3f9f17-bbea-4de5-abd4-9daced3e0663
# ╠═bb6a7bd1-c1f1-4897-9745-a21d739c21c8
# ╠═d8c8d4a6-edac-40b1-a5b1-9371c6391376
# ╠═d19a2fcd-6e9f-4999-b142-4727b23073db
# ╠═ec2c5122-8382-4011-8281-74d234a7e0c7
# ╟─601bea2d-0863-4387-8b66-4e916c030e16
# ╠═0eb0ff0e-9644-4cd7-be61-900d223eb88c
# ╠═055eadf4-8d4d-4177-b764-e30ebedccd8f
# ╠═b7459187-c9d6-4c14-a2d2-4988a1043d1f
# ╠═2b7b7a40-394e-4a15-a7eb-3f46bdc93d7f
# ╠═e9197e73-18ae-4e3a-af8e-b642eff7506d
# ╠═f2621f40-fb8b-42e6-8d83-42164434369b
# ╠═a85c1df8-5eb8-4e00-94ad-9d496d15bfde
# ╠═dc65119f-7f3c-42e0-853e-f0b153d83356
# ╠═0d3adcc2-3c42-4c5f-a9fd-86985f0b1364
# ╠═239d3bf5-0eab-4e7c-8f1d-a50d9c826160
# ╟─c066178c-470c-4a8e-98b6-5ac3f427ef0b
# ╠═b8c55aba-edb4-493b-8e8a-2a15e77c48b5
# ╠═6107da8f-6fab-42f4-b18a-0c82c862969d
# ╠═05d79851-ef16-4359-a5ca-56c040ca141b
# ╠═7d83955b-909c-4628-bc0d-5a3208cbec6e
# ╠═09ab1dad-5cc8-441e-bd90-46f62839d07c
# ╠═4e7fd906-ab06-48ab-b599-b33df1984bea
# ╠═376b6890-5f6d-4448-bc33-c02d8c66517f
# ╠═a5349b56-3f7a-45ab-ab1a-372d8e5bb2c7
# ╠═2320e500-90aa-429d-9973-d991f9e9445a
# ╠═be636d76-f6b6-46c6-aabe-51ca944dc744
# ╠═c5338429-383e-4311-b740-e5390de4cb09
# ╠═ffe721dd-7a74-4b7d-9d82-c9dba69017e8
# ╠═d4766288-6faa-401c-974e-7c09d0d665c0
# ╠═d313b6ac-d3f9-4a45-adcb-6a1da2759d07
# ╠═ac6bd368-20ac-4665-8522-cf17b88175ee
# ╠═8c19e038-425e-423a-bdef-f6bf9ab14ada
# ╠═e833942a-b45e-42f2-8743-d3da9dc12aa3
# ╠═d57ad250-ad79-41b7-9eca-ecbf2fd08265
