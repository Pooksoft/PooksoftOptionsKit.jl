using PooksoftOptionsKit

# create options struct -
option_parameters = PSOptionKitPricingParameters(349.72, 0.3124, (7.0/365.0),7,360.0,0.17,0.0098)

# estimate the implied volatility -
iv = estimate_implied_volatility(2.12,option_parameters)