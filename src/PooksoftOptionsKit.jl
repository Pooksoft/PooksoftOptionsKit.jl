module PooksoftOptionsKit

# include -
include("Include.jl")

# export methods -
export compute_call_option_profit_loss_at_expiration
export compute_put_option_profit_loss_at_expiration

# export types -
export PSResult
export PSError
export PSAbstractOptionContract
export PSCallOptionContract
export PSPutOptionContract

end # module
