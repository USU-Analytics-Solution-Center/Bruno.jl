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
    equal-contrib: true
    affiliation: 1
  - name: Spencer Clemens
    equal-contrib: true 
    affiliation: 1
  - name: Tyler Brough
    equal-contrib: false
    affiliation: 1
  - name: Pedram Jahangiry
    equal-contrib: false
    affiliation: 1
  - name: Janette Goodridge
    equal-contrib: false
    affiliation: 1
affiliations:
 - name: Utah State University
   index: 1
date: 10 December 2022
bibliography: paper.bib
---

# Summary

When engaging in activities in financial markets, market makers and other financial practitioners face a variety of risks. Many attempt to offset these risks by hedging. Hedging involves taking an offsetting position in an investment or asset, allowing potential risks to be mitigated. Hedging is often accomplished using financial derivatives. Derivatives are financial instruments that derive their value from an underlying asset. Some popular examples of financial derivatives include futures, forwards, options, and swaps.

Bruno is a Julia package that allows for comparison of different hedging and trading strategies, many of which are based on financial derivatives.

# Statement of need

Bruno allows users to compare different financial derivatives hedging and trading strategies. One of the major benefits of Bruno is that it can calculate historical derivative prices. This is important because derivative price data is not publicly available. Thus, many trading and hedging strategies, by necessity, are currently based on asset prices. Bruno will allow them to be based on derivative prices instead.

Another key feature of Bruno is that it has the ability to produce a distribution of maximum loss that could result from a trading or hedging strategy. This information would be valuable to financial practitioners and market makers as it would help to quantifying the risk of a potential strategy before putting the strategy into place. Furthermore, it would allow for comparison of different trading and hedging strategies. Creation of these distributions is facilitated by Bruno’s data generating processes. These processes include non-parametric methods, such as the stationary bootstrap, as well as parametric methods such as log diffusion.

Bruno was designed to used by finance professionals and academics alike. Financial analysis of trading and hedging strategies can be intensive. Thispackage is intended to make this type of investigation more straightforward and accessible. There are many other software packages that have the capacity to calculate derivative prices, simulate hedging, and generate data. However, none of them have been compiled in a manner that allows for complete analysis. Rather, each package performs one part of the process independently, and must be assembled by the software user. Bruno is novel because it allows for complete analysis in a single package. Bruno was recently used in a conference publication, with several other publications nearing completion.

# Acknowledgements

We acknowledge support from Analytics Solutions Center at the department of Data Analytics and Information Systems (DAIS) at Utah State University, Huntsman School of Business.

# References
