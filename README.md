Bruno is a modular, flexible package for simulating financial data, asset pricing, and trading strategy testing. 

Bruno is written and maintained by the [Analytics Solution Center](https://huntsman.usu.edu/asc/index) at Utah State University.  

## Contents
* [Installation instructions](#installation-instructions)
* [What Bruno can do](#what-bruno-can-do)
* [Creating FinancialInstruments](#creating-fiancialinstruments)
* [Citing](#citing)
* [Contributing](#contributing)

## Installation Instructions

is a [registered Julia package](https://julialang.org/packages/). So to install it,

1. [Download Julia](https://julialang.org/downloads/).

2. Launch Julia and type

```julia
julia> using Pkg

julia> Pkg.add("Bruno")
```
## What Bruno can do
Bruno's four main functions are 
* Describe financial tools like stock options and commodity futures with an intuitive type system
* Generate simulated time-series data with parametric and non-parametric models
* Price complex assets
* Test trading or hedging strategies with historical or simulated prices

## Pricing your first asset
```julia
using Bruno
stock = Stock(50; volatility=0.3)
call = EuroCallOption(stock, 55; maturity=.5)
price!(call, BlackScholes)
```

Check out [the documentation](https://usu-analytics-solution-center.github.io/Bruno.jl/) for more examples and tutorials. 

## Citing
If you use Bruno.jl as part of your research, teaching, or other activities, we would be grateful if you could cite our work and mention Bruno.jl by name.

```
@misc{Bruno.jlPackage,
  author = {Mitchell Pound and Spencer Clemens and The Analytics Solution Center at Utah State University}
  title = {Bruno.jl}
  year = {2022}
  url = {https://usu-analytics-solution-center.github.io/Bruno.jl/}
}
```

## Contributing
If you're interested in contributing, we'd LOVE your help!
We are always looking to expand the community and make Bruno better. 

If you'd like to work on a new feature, or if you're new to open source and want to crowd-source neat projects that fit your interests, you should [start a discussion](https://github.com/USU-Analytics-Solution-Center/Bruno.jl//discussions/new?) right away.

For more information check out our contributor's guide.
