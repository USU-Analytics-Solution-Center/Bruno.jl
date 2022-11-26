# Pricing Models

```@docs
price!(::Any, ::Type{<:Any})
price!(::Option, ::Type{BlackScholes})
price!(::Option, ::Type{BinomialTree})
price!(::Option, ::Type{MonteCarlo{LogDiffusion}})
```