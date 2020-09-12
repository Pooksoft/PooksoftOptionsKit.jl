using PooksoftOptionsKit
using PyPlot

# call -
result_buyer = compute_call_option_profit_loss_at_expiration(:buy, 20.0, 1.20, 0.0, 40.0)
result_seller = compute_call_option_profit_loss_at_expiration(:sell, 20.0, 1.20, 0.0, 40.0)

profit_loss_buyer = result_buyer.value
profit_loss_seller = result_seller.value

# plot -
plot(profit_loss_buyer[:,1], profit_loss_buyer[:,3], "b")       # buyer - payoff
#plot(profit_loss_buyer[:,1], profit_loss_buyer[:,2], "b--")     # buyer - P/L   
#plot(profit_loss_seller[:,1], profit_loss_seller[:,2], "r")       # buyer - payoff
#plot(profit_loss_seller[:,1], profit_loss_seller[:,2], "r--")     # buyer - P/L   