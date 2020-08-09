using PooksoftOptionsKit
using PyPlot
using Dates
using Distributions

# setup components -
callOptionContractShort = PSCallOptionContract("AMD", Date(2020,8,07), 105.0, 1.50, 1; sense=:sell)
callOptionContractLong = PSCallOptionContract("AMD", Date(2020,8,07), 100.0, 3.30, 1; sense=:buy)

# create set -
assetSet = Set{PSAbstractAsset}()
push!(assetSet, callOptionContractShort)
push!(assetSet, callOptionContractLong)

# calculate the PL -
result = compute_multileg_profit_and_loss_at_expiration(assetSet, 95.0, 110.0; number_of_price_steps=1000)

# plot -
profit_array = result.value
plot(profit_array[:,1], profit_array[:,2], "r--")     # buyer - P/L   
plot(profit_array[:,1], zeros(1000))

# sample -
IV = 0.68
DTE = 24
price = 54.72
sigma = price*IV*sqrt(DTE/365)
d = Normal(price,sigma)

# generate sample future prices -
future_price_array = rand(d,100)
sample_result = compute_multileg_profit_and_loss_at_expiration(assetSet,future_price_array)
sample_array = sample_result.value
