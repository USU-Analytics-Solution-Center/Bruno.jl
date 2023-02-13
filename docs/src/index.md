# Welcome to Bruno.jl!

## What is Bruno?
Bruno is a modular, flexible package for simulating financial data, asset pricing, and trading strategy testing. 

The [Analytics Solution Center](https://huntsman.usu.edu/asc/index) at Utah State University is responsible for writing and maintaining Bruno.

## What Bruno can do
Bruno's four main functions are 
* Describe financial tools like stock options and commodity futures with an intuitive type system
* Generate simulated time-series data with parametric and non-parametric models
* Price complex assets
* Test trading or hedging strategies with historical or simulated prices

## Why Bruno?
Financial analysis of trading and hedging strategies can be intensive. This package is intended to make this type of investigation more straightforward and accessible. There are many other software packages that have the capacity to calculate derivative prices, simulate hedging, or generate data. However, none of them have been compiled in a manner that allows for integrated analysis. Rather, each package performs one part of the process independently, and must be assembled by the software user. In contrast, Bruno is novel because it provides a replacement to these independent packages with a fully integrated set of tools for derivatives analysis designed to work in a unified manner in Julia.

## Installation Instructions

1. [Download Julia](https://julialang.org/downloads/).
2. Bruno is a [registered Julia package](https://julialang.org/packages/). So to install it, Launch Julia and type:

```julia
julia> using Pkg

julia> Pkg.add("Bruno")
```

!!! compat "Julia 1.6 or newer"
    The latest version of Bruno strongly suggests _at least_ Julia 1.8 or later to run.
    While most scripts will run on Julia 1.6 or 1.7, Bruno is _only_ tested on Julia 1.8.

## Pricing your first asset
```julia
using Bruno
stock = Stock(50; volatility=0.3)
call = EuroCallOption(stock, 55; maturity=.5)
price!(call, BlackScholes)
```

Check out [the tutorials](https://usu-analytics-solution-center.github.io/Bruno.jl/tutorials/fin_inst/base_asset/) for more examples. 

## Getting In Touch

Whether you need help getting started with Bruno, found a bug, want Bruno to be even better, or just want to chat about computational economics and finance, there are two ways of contacting us:

* [Start a discussion](https://github.com/USU-Analytics-Solution-Center/Bruno.jl/discussions). This is great for general questions about numerics, computation finance, experimental or under-documented features, and for getting help setting up a cool new trading strategy simulation.
* [Open an issue](https://github.com/USU-Analytics-Solution-Center/Bruno.jl/issues). Issues are best if you think the Bruno source code needs attention: such as a bug, a type inconsistency error (😱), an important missing feature, or a typo in this documentation 👀.

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

For more information check out our [contributor's guide](https://github.com/USU-Analytics-Solution-Center/Bruno.jl/blob/main/CONTRIBUTING.md).
