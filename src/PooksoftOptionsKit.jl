module PooksoftOptionsKit

# include -
include("Include.jl")

# export methods -
export compute_option_profit_and_loss_at_expiration

# methods for pricing options (uses binary tree)
export build_binary_price_tree
export build_ternary_price_tree
export option_contract_price

# implied volatility -
export estimate_implied_volatility

# the greeks -
export delta
export theta
export gamma
export vega
export rho

# export types -
export PSCallOptionContract
export PSPutOptionContract
export PSEquityAsset

# Parameters for greek calculation -
export PSOptionKitPricingParameters

# Binary tree -
export PSBinaryPriceTreeNode
export PSBinaryPriceTree

# Ternary tree -
export PSTernaryPriceTreeNode
export PSTernaryPriceTree

export path_to_package

end # module
