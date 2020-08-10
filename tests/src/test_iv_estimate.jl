using PooksoftOptionsKit
using Dates

# what is the stock price?
stock_price = 54.17
implied_volatility = 0.67
DTE = (31.0/365.0)
number_of_levels = 12
risk_free_rate = 0.15 # this is in percent
dividend_rate = 0.0 # this is in percent
strike_price = 60.0
premium_value = 2.06

# setup options calculation -
amd_option_parameters = PSOptionKitPricingParameters(implied_volatility, DTE, number_of_levels, risk_free_rate, dividend_rate)

# setup asset contract -
callOptionContract = PSCallOptionContract("AMD", Date(2020,6,25), strike_price, premium_value, 1)

# estimate the implied volatility -
iv = estimate_implied_volatility(callOptionContract,amd_option_parameters,stock_price)