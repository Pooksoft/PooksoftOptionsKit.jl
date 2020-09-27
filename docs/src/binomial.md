# Lattice pricing models

### Background
The binomial option pricing model is an options valuation method developed by [Cox et al in 1979](https://www.sciencedirect.com/science/article/abs/pii/0304405X79900151?via%3Dihub).
The binomial option pricing model uses an iterative procedure, allowing for the specification of nodes, or points in time, during the time span between the valuation date and the option's expiration date.

The ternary (or trinomial) option pricing model is an option pricing model incorporating three possible values that an underlying asset can have in one time period. The three possible values the underlying asset can have in a time period may be greater than, the same as, or less than the current value.

The trinomial option pricing model differs from the binomial option pricing model in one key aspect by incorporating another possible value in one time period. Under the binomial option pricing model, it is assumed that the value of the underlying asset will either be greater than or less than, its current value. The trinomial model, on the other hand, incorporates a third possible value, which incorporates a zero change in value over a time period. This assumption makes the trinomial model more relevant to real life situations, as it is possible that the value of an underlying asset may not change over a time period, such as a month or a year.

```@docs
option_contract_price
```
