var documenterSearchIndex = {"docs":
[{"location":"profit_and_loss/#Profit-and-loss-simulations-at-expiration","page":"Profit and loss simulations at expiration","title":"Profit and loss simulations at expiration","text":"","category":"section"},{"location":"profit_and_loss/","page":"Profit and loss simulations at expiration","title":"Profit and loss simulations at expiration","text":"compute_option_profit_and_loss_at_expiration","category":"page"},{"location":"profit_and_loss/#PooksoftOptionsKit.compute_option_profit_and_loss_at_expiration","page":"Profit and loss simulations at expiration","title":"PooksoftOptionsKit.compute_option_profit_and_loss_at_expiration","text":"compute_option_profit_and_loss_at_expiration(assetSet::Set{PSAbstractAsset}, assetPriceArray::Array{Float64,1})::(Union{PooksoftBase.PSResult{T}, Nothing} where T<:Any)\n\nCompute the overall profit and loss (P/L) for a set option contracts with the same expiration date, and underlying asset.\n\nArguments\n\nassetSet::Set{PSAbstractAsset}: A set containing the put and call contract models in this trade. \nassetPriceArray::Array{Float64,1}: An 1d array containing underlying asset prices to be used in the P/L calculation for this trade \n\n\n\n\n\ncompute_option_profit_and_loss_at_expiration(assetSet::Set{PSAbstractAsset}, assetPriceStart::Float64, assetPriceStop::Float64; \n    number_of_price_steps::Int64=1000)::(Union{PooksoftBase.PSResult{T}, Nothing} where T<:Any)\n\nCompute the overall profit and loss (P/L) for a set option contracts with the same expiration date, and underlying asset.\n\nArguments\n\nassetSet::Set{PSAbstractAsset}: A set containing the put and call contract models in this trade. \nassetPriceStart::Float64: The start price for the underlying asset used to calculate the P/L values in this trade \nassetPriceStop::Float64: The start price for the underlying asset used to calculate the P/L values in this trade\nnumber_of_price_steps::Int64=1000: keyword arg describing the number of steps to take between the start and stop price. Default: 1000\n\n\n\n\n\ncompute_option_profit_and_loss_at_expiration(assetSet::Set{PSAbstractAsset}, underlyingPriceRange::Tuple{Float64,Float64,Int64})::(Union{PooksoftBase.PSResult{T}, Nothing} where T<:Any)\n\nCompute the overall profit and loss (P/L) for a set option contracts with the same expiration date, and underlying asset.\n\nArguments\n\nassetSet::Set{PSAbstractAsset}: A set containing the put and call contract models in this trade. \nunderlyingPriceRange::Tuple{Float64,Float64,Int64}: A tuple containing the price start, price stop and number of steps between the start and stop price to be used in the P/L calculation for this trade \n\n\n\n\n\n","category":"function"},{"location":"price/#Price-models","page":"Price models","title":"Price models","text":"","category":"section"},{"location":"binary/#Binary-price-model","page":"Binary price model","title":"Binary price model","text":"","category":"section"},{"location":"binary/#Can-stuff-go-here?","page":"Binary price model","title":"Can stuff go here?","text":"","category":"section"},{"location":"binary/","page":"Binary price model","title":"Binary price model","text":"option_contract_price","category":"page"},{"location":"binary/#PooksoftOptionsKit.option_contract_price","page":"Binary price model","title":"PooksoftOptionsKit.option_contract_price","text":"option_contract_price(contractSet::Set{PSAbstractAsset}, latticeModel::PSBinaryLatticeModel, baseUnderlyingPrice::Float64; \n    earlyExercise::Bool = false)::PooksoftBase.PSResult\n\nEstimate the price of a contract using a binary lattice pricing model.\n\n\n\n\n\n","category":"function"},{"location":"#PooksoftOptionsKit.jl","page":"PooksoftOptionsKit.jl","title":"PooksoftOptionsKit.jl","text":"","category":"section"}]
}
