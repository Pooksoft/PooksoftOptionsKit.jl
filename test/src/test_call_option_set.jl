using PooksoftOptionsKit
using PyPlot
using Dates

# assetSet -
assetSet = Set{PSAbstractAsset}()

# setup the option object -
callOptionContract = PSCallOptionContract("AAPL", Date(2020,6,25), 100.0, 1.20, 1; sense=:buy)
push!(assetSet, callOptionContract)

# compute -
result_buyer = compute_option_profit_and_loss_at_expiration(assetSet,90.0,110.0)

# plot -
profit_loss_buyer = result_buyer.value
plot(profit_loss_buyer[:,1], profit_loss_buyer[:,2], "b--")     # buyer - P/L   ]
plot(profit_loss_buyer[:,1], zeros(1000))