using PooksoftOptionsKit
using PyPlot
using Dates
using Distributions

# setup the call test -
data = Array{Float64,1}()
stock_price = 54.17
implied_volatility = 0.67
DTE = (24.0/365.0)
number_of_levels = 12
risk_free_rate = 0.15 # this is in percent
dividend_rate = 0.0 # this is in percent

# setup options calculation -
amd_option_parameters = PSOptionKitPricingParameters(implied_volatility, DTE, number_of_levels, risk_free_rate, dividend_rate)

# setup components -
callOptionContractShort = PSCallOptionContract("AMD", Date(2020,8,07), 60.0, 1.50, 1; sense=:sell)
callOptionContractLong = PSCallOptionContract("AMD", Date(2020,8,07), 50.0, 2.07, 1; sense=:buy)

# create set -
assetSet = Set{PSAbstractAsset}()
push!(assetSet, callOptionContractShort)
push!(assetSet, callOptionContractLong)

# what prices to we want to look at?
assetPriceArray = collect(range(40.0,stop=80.0,length=20))
for (index,asset_price) in enumerate(assetPriceArray)

    # build the pricing tree -
    tree = build_ternary_price_tree(assetSet, amd_option_parameters, asset_price)

    # compute -
    local result = option_contract_price(tree, amd_option_parameters)

    # grab -
    push!(data,result.value)
end

# plot -
plot(assetPriceArray,data)

# compute -
assetPriceArrayAtExp = collect(range(40.0,stop=80.0,length=1000))
result = compute_option_profit_and_loss_at_expiration(assetSet, assetPriceArrayAtExp)
pl_data = result.value
plot(pl_data[:,1],pl_data[:,2],"r")