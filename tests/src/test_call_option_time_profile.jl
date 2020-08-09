using PooksoftOptionsKit
using PyPlot

# create base options struct -
option_parameters = PSOptionKitPricingParameters(349.72, 0.3124, (7.0/365.0),7,360.0,0.17,0.0098);

# what prices to we want to look at?
assetPriceArray = collect(range(340.0,stop=380.0,length=20))

# compute -
optionContractPriceArray = option_contract_price(assetPriceArray, option_parameters; modelTreeType=:ternary)

# compute the payoff at expiration -
result_buyer = compute_call_option_profit_loss_at_expiration(:buy, 360.0, 1.20, 340.0, 380.0)
profit_loss_buyer = result_buyer.value

# make a plot -
plot(profit_loss_buyer[:,1], (1.0/100)*profit_loss_buyer[:,3], "b")       # buyer - payoff
plot(assetPriceArray,optionContractPriceArray.value, color="r")
plot(assetPriceArray,optionContractPriceArray.value, "o", markerfacecolor="w", mec="r")
