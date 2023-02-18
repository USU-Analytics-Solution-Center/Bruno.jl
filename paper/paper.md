---
title: 'Bruno: A Julia package for simulation, financial asset pricing and delta hedging'
tags:
  - Julia
  - Financial instruments
  - Hedging 
  - Options
  - Simulation
authors:
  - name: Mitchell Pound
    affiliation: 1
  - name: Spencer Clemens
    affiliation: 1
  - name: Tyler Brough
    affiliation: 1
  - name: Pedram Jahangiry
    affiliation: 1
  - name: Janette Goodridge
    affiliation: 1
affiliations:
 - name: Utah State University
   index: 1
date: 10 December 2022
bibliography: paper.bib
---

# Summary

When engaging in activities in financial markets, market makers and other financial practitioners face a variety of risks. Many attempt to offset these risks by hedging. Hedging involves taking an offsetting position in an investment or asset, allowing potential risks to be mitigated and transferred to investors willing to take the risk [@culp2011risk]. Hedging is often accomplished using financial derivatives. Derivatives are financial instruments that derive their value from an underlying asset [@mcdonald_2013]. Some popular examples of financial derivatives include futures, forwards, options, and swaps.

Bruno is a Julia [@bezanson2017julia] package that allows for comparison of different hedging and trading strategies, many of which are based on financial derivatives.

# Statement of need

Bruno allows users to compare different financial derivatives hedging and trading strategies. One of the major benefits of Bruno is that it can calculate theoretical historical derivative prices for a variety of pricing models such as the Black-Scholes model[@black1973pricing] and Monte Carlo analysis[@clewlow_strickland_1998]. This is important because derivative price data is not publicly available. Thus, many trading and hedging strategies, by necessity, are currently based on asset prices. Bruno will allow them to be based on theoretical derivative prices instead.

Another key feature of Bruno is that it has the ability to produce a distribution of maximum loss that could result from a trading or hedging strategy. This information would be valuable to financial practitioners and market makers as it would help to quantify the risk of a potential strategy before putting the strategy into place. Furthermore, it would allow for comparison of different trading and hedging strategies. Creation of these distributions is facilitated by Bruno’s data generating processes. These processes include non-parametric methods, such as the stationary bootstrap [@politis1994stationary] with automatic block-length selection [@politis2004automatic][@patton2009correction] as well as parametric methods such as log diffusion.

Bruno was designed to be used by finance professionals and academics alike. Financial analysis of trading and hedging strategies can be intensive. This package is intended to make this type of investigation more straightforward and accessible. There are many other software packages that have the capacity to calculate derivative prices, simulate hedging, and generate data. For example, in Julia, FinancialDerivatives.jl [@financialderivativesjl], FinancialMonteCarlo.jl [@financialmontecarlojl], and Strategems.jl [@strategemsjl] are packages that can be used for derivative asset pricing, data simulation, and strategy testing, respectively. However, none of them have been compiled in a manner that allows for integrated analysis. Rather, each package performs one part of the process independently, and must be assembled by the software user. In contrast, Bruno is novel because it provides a replacement to these independent packages with a fully integrated set of tools for derivatives analysis designed to work in a unified manner. Bruno was recently used in a conference publication[@pound_2022], with several other publications nearing completion.

# Example usage

## Defining a strategy
Here we demonstrate how to define and use a trading strategy for testing. In this example, a strategy is defined where a derivative asset and its underlying stock is bought every Friday and held until the end of the month. The `buy` and `sell` functions are provided by Bruno to make defining a strategy easier.

```julia 
using Bruno

# creating a new strategy subtype for dispatch
primitive type ExampleStrategy <: Hedging 8 end


# define the new strategy 
import Bruno: buy, sell, strategy
function Bruno.strategy(fin_obj, 
                pricing_model, 
                strategy_mode::Type{ExampleStrategy},
                holdings,
                step;
                kwargs...)

    if step % 5 == 0
        # buy one FinancialInstrument every 5 days with no transaction costs
        buy(fin_obj, 1, holdings, pricing_model, 0) 
        # buy one Stock every 5 days
        buy(fin_obj.widget, 1, holdings, pricing_model, 0) 
    end
    return holdings
end
```

## Setting up assets and running the strategy

Using the type system for derivatives assets in Bruno, we define assets to be used in the strategy and run the strategy on simulated data from log diffusion models. This example uses a European stock option priced using the Black Scholes model. It is important to note that alternative pricing and data simulation models could be used simply by changing the types used. This means strategies can be analyzed using a variety of assumptions about the asset and market conditions. 
All logic for interest accrued during the time steps as well as transaction costs are all handled by the simulation environment. The code returns the cumulative return from the simulated strategy as well as the agent's holdings in the agent's portfolio at each timestep along the simulation. Thus, for more complicated strategies such as those that depend on the derivative or the underlying asset, the holdings can be analyzed using common statistical time series tools. 

```julia
# create a random array to act as historic prices
historic_prices = rand(50:75, 40)

# create stock from daily 'historic' prices
stock = Stock(;
    prices=historic_prices, 
    name="example_stock", 
    timesteps_per_period = 252
)

# create European stock call option using the defined stock
option = EuroCallOption(stock, 60)

# create vector of simulated future prices using the log diffusion model
input = LogDiffInput(; 
    nTimeStep=252, 
    initial=50, 
    volatility=.3,
    drift=.08
)
future_prices = vec(makedata(input, 1))

# run the strategy for 20 days assuming all prices are daily
cumulative_returns, holdings = strategy_returns(
    option, 
    BlackScholes, 
    ExampleStrategy,
    future_prices, 
    20, 
    252
)
```

# Acknowledgements

We acknowledge support from Analytics Solutions Center at the department of Data Analytics and Information Systems (DAIS) at Utah State University, Huntsman School of Business.

# References
