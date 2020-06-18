module PooksoftOptionsKit

# include -
include("Include.jl")

# export methods -
export compute_call_option_profit_loss_at_expiration
export compute_put_option_profit_loss_at_expiration
export compute_equity_asset_profit_loss_at_expiration
export compute_complex_trade_profit_and_loss_at_expiration
export build_binary_price_tree

# export types -
export PSResult
export PSError
export PSAbstractAsset
export PSCallOptionContract
export PSPutOptionContract
export PSEquityAsset

end # module
