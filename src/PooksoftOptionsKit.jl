module PooksoftOptionsKit

# include -
include("Include.jl")

# export methods -
export compute_call_option_profit_loss_at_expiration
export compute_put_option_profit_loss_at_expiration
export compute_equity_asset_profit_loss_at_expiration
export compute_complex_trade_profit_and_loss_at_expiration

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
export PSResult
export PSError
export PSAbstractAsset
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

end # module
