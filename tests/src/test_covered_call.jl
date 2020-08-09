using PooksoftOptionsKit
using PyPlot
using Dates

# setup components -
callOptionContract = PSCallOptionContract("AAPL", Date(2020,6,25), 100.0, 1.20, 1; sense=:sell)
equityObject = PSEquityAsset("AAPL", 80.0, 100, Date(2020,6,4))
putOptionContract = PSPutOptionContract("AAPL", Date(2020,6,25), 60.0, 5.00, 1; sense=:buy)

# create set -
assetSet = Set{PSAbstractAsset}()
#push!(assetSet, callOptionContract)
push!(assetSet, equityObject)
push!(assetSet, putOptionContract)

# calculate the PL -
result = compute_complex_trade_profit_and_loss_at_expiration(assetSet, 0.0, 140.0; number_of_price_steps=1000)

# plot -
profit_array = result.value
plot(profit_array[:,1], profit_array[:,2], "r--")     # buyer - P/L   
plot(profit_array[:,1], zeros(1000))