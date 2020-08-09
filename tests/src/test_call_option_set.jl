using PooksoftOptionsKit
using PyPlot
using Dates

# setup the option object -
callOptionContract = PSCallOptionContract("AAPL", Date(2020,6,25), 100.0, 1.20, 1; sense=:buy)

# compute -
result_buyer = compute_call_option_profit_loss_at_expiration(callOptionContract,0.0,120.0)

# plot -
profit_loss_buyer = result_buyer.value
plot(profit_loss_buyer[:,1], profit_loss_buyer[:,2], "b--")     # buyer - P/L   