# Type System

## Types

### Base Assets (Widgets)

```@docs
Widget
Stock
Commodity
Bond
```

### Financial Instruments (Derivatives)

#### Abstract types

```@docs
FinancialInstrument
Option
CallOption
PutOption
```
#### Concrete types

```@docs
Future
EuroCallOption
AmericanCallOption
EuroPutOption
AmericanPutOption
```

## Constructors

### Base Asset Constructors

```@docs
Stock(::Real)
Commodity(::Real)
Bond(::Real)
```

### Financial Instrument Constructors

```@docs
EuroCallOption(::Widget, ::Real)
AmericanCallOption(::Widget, ::Real)
EuroPutOption(::Widget, ::Real)
AmericanPutOption(::Widget, ::Real)
```