# Computing The Greeks

### Background
The Greeks is a term used in the options market to describe the different dimensions of risk involved in taking an options position. These variables are called Greeks because they are typically associated with Greek symbols. 
Each risk variable is a result of an imperfect assumption or relationship of the option with another underlying variable. Traders use different Greek values, such as delta, theta, and others, to assess options risk and manage option portfolios. 

#### Delta
Delta represents the rate of change between the option's price and a 1-dollar change in the underlying asset's price. In other words, the price sensitivity of the option relative to the underlying. Delta of a call option has a range between zero and one, while the delta of a put option has a range between zero and negative one. For example, assume an investor is long a call option with a delta of 0.50. Therefore, if the underlying stock increases by 1-dollar, the option's price would theoretically increase by 50 cents.

For options traders, delta also represents the hedge ratio for creating a delta-neutral position. For example if you purchase a standard American call option with a 0.40 delta, you will need to sell 40 shares of stock to be fully hedged. Net delta for a portfolio of options can also be used to obtain the portfolio's hedge ration.

A less common usage of an option's delta is it's current probability that it will expire in-the-money. For instance, a 0.40 delta call option today has an implied 40-percent probability of finishing in-the-money. 

```@docs
delta
```

#### Theta
Theta represents the rate of change between the option price and time, or time sensitivity - sometimes known as an option's time decay. Theta indicates the amount an option's price would decrease as the time to expiration decreases, all else equal. For example, assume an investor is long an option with a theta of -0.50. The option's price would decrease by 50 cents every day that passes, all else being equal.

Theta increases when options are at-the-money, and decreases when options are in- and out-of-the money. Options closer to expiration also have accelerating time decay. Long calls and long puts will usually have negative Theta; short calls and short puts will have positive Theta. By comparison, an instrument whose value is not eroded by time, such as a stock, would have zero Theta.

```@docs
theta
```

#### Gamma
Gamma represents the rate of change between an option's delta and the underlying asset's price. This is called second-order (second-derivative) price sensitivity. Gamma indicates the amount the delta would change given a 1-dollar move in the underlying security. For example, assume an investor is long one call option on hypothetical stock XYZ. The call option has a delta of 0.50 and a gamma of 0.10. Therefore, if stock XYZ increases or decreases by 1-dollar, the call option's delta would increase or decrease by 0.10.

Gamma is used to determine how stable an option's delta is: higher gamma values indicate that delta could change dramatically in response to even small movements in the underlying price. Gamma is higher for options that are at-the-money and lower for options that are in- and out-of-the-money, and accelerates in magnitude as expiration approaches. Gamma values are generally smaller the further away from the date of expiration; options with longer expirations are less sensitive to delta changes. As expiration approaches, gamma values are typically larger, as price changes have more impact on gamma.

Options traders may opt to not only hedge delta but also gamma in order to be delta-gamma neutral, meaning that as the underlying price moves, the delta will remain close to zero.

```@docs
gamma
```