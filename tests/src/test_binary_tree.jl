using PooksoftOptionsKit
using PyPlot
using Dates

# setup the call test -
stock_price = 54.17
implied_volatility = 0.67
DTE = (31.0/365.0)
number_of_levels = 4
risk_free_rate = 0.15 # this is in percent
dividend_rate = 0.0 # this is in percent

# setup options calculation -
amd_option_parameters = PSOptionKitPricingParameters(implied_volatility, DTE, number_of_levels, risk_free_rate, dividend_rate)

# setup an amd call option -
assetSet = Set{PSAbstractAsset}()
callOptionContract = PSCallOptionContract("AMD", Date(2020,6,25), 60.0, 0.0, 1; sense=:buy, contractMultiplier=1.0)
push!(assetSet, callOptionContract)    

# build the pricing tree -
tree = build_binary_price_tree(assetSet, amd_option_parameters, stock_price)

# compute -
result = option_contract_price(tree, amd_option_parameters)
