# [Type System](@id Type_system)

## Types

### [Base Assets (Widgets)](@id Widgets)

```@docs
Widget
Stock
Commodity
Bond
```

### [Financial Instruments (Derivatives)](@id Fin_instruments)

#### Abstract Types

```@docs
FinancialInstrument
Option
CallOption
PutOption
```
#### Concrete Types

```@docs
Future
EuroCallOption
AmericanCallOption
EuroPutOption
AmericanPutOption
```

## [Constructors](@id Constructors)

### [Base Asset Constructors](@id Widget_constructors)

```@docs
Stock(::Real)
Commodity(::Real)
Bond(::Real)
```

### [Financial Instrument Constructors](@id Fin_inst_constructors)

```@docs
EuroCallOption(::Widget, ::Real)
AmericanCallOption(::Widget, ::Real)
EuroPutOption(::Widget, ::Real)
AmericanPutOption(::Widget, ::Real)
```