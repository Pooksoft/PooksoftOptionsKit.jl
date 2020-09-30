# --- PRIVATE METHODS --------------------------------------------------------------------------------------- #
function _compute_profit_loss_at_expiration(asset::PSAbstractAsset, assetPriceValueArray::Array{Float64,1})::Array{Float64,1}

    # initialize -
    pl_value_array = Array{Float64,1}()

    # compute the intrinsic value -
    for (index, asset_price_value) in enumerate(assetPriceValueArray)
        result = intrinsic_value(asset,asset_price_value)
        if (isa(result.value,Exception) == true)
            return result
        end
        pl_value = result.value.pl_value
        
        # grab -
        push!(pl_value_array,pl_value)
    end

    # call -
    return pl_value_array
end

function _compute_profit_loss_at_expiration(asset::PSAbstractAsset, assetPriceStart::Float64, assetPriceStop::Float64; 
    number_of_price_steps::Int64=1000)::Array{Float64,1}

    # initialize -
    profit_loss_array = Array{Float64,1}()

    # setup price range -
    asset_price_range = collect(range(assetPriceStart, assetPriceStop,length=number_of_price_steps))

    # return -
    return _compute_profit_loss_at_expiration(asset, asset_price_range)
end
# ----------------------------------------------------------------------------------------------------------- #

# --- PUBLIC METHODS ---------------------------------------------------------------------------------------- #
"""
    
    compute_option_profit_and_loss_at_expiration(assetSet::Set{PSAbstractAsset}, assetPriceArray::Array{Float64,1})::(Union{PooksoftBase.PSResult{T}, Nothing} where T<:Any)

Compute the overall profit and loss (P/L) for a set option contracts with the same expiration date, and underlying asset.

# Arguments 
- `assetSet::Set{PSAbstractAsset}`: A set containing the put and call contract models in this trade. 
- `assetPriceArray::Array{Float64,1}`: An 1d array containing underlying asset prices to be used in the P/L calculation for this trade 
"""
function compute_option_profit_and_loss_at_expiration(assetSet::Set{PSAbstractAsset}, assetPriceArray::Array{Float64,1})::(Union{PSResult{T}, Nothing} where T<:Any)

    # TODO error checks -

    # get -
    number_of_price_steps = length(assetPriceArray)

    # initialize -
    number_of_assets = length(assetSet)
    assetProfitLossArray = zeros(number_of_price_steps, number_of_assets)
    tradeProfitLossArray = zeros(number_of_price_steps,2) # firstCol: price, secondCol: PL

    # process the set of assets -
    for (assetIndex, assetObject) in enumerate(assetSet)
        
        # process each asset type -
        profit_loss_array = _compute_profit_loss_at_expiration(assetObject, assetPriceArray)

        # add the PL for this asset to the overall array -
        for index = 1:number_of_price_steps
            assetProfitLossArray[index,assetIndex] = profit_loss_array[index]
        end
    end

    # ok, so the assetProfitLossArray holds the PL for each asset type in its cols -
    # to get the PL for the entire trade at a particular stock price, then sum across the cols -
    for price_index = 1:number_of_price_steps
        
        # grab col -
        tmp_row = assetProfitLossArray[price_index,:]
    
        # add - 
        tradeProfitLossArray[price_index,1] = assetPriceArray[price_index]
        tradeProfitLossArray[price_index,2] = sum(tmp_row)
    end

    # return -
    return PSResult{Array{Float64,2}}(tradeProfitLossArray)
end

"""
    compute_option_profit_and_loss_at_expiration(assetSet::Set{PSAbstractAsset}, assetPriceStart::Float64, assetPriceStop::Float64; 
        number_of_price_steps::Int64=1000)::(Union{PooksoftBase.PSResult{T}, Nothing} where T<:Any)

Compute the overall profit and loss (P/L) for a set option contracts with the same expiration date, and underlying asset.

# Arguments 
- `assetSet::Set{PSAbstractAsset}`: A set containing the put and call contract models in this trade. 
- `assetPriceStart::Float64`: The start price for the underlying asset used to calculate the P/L values in this trade 
- `assetPriceStop::Float64`: The start price for the underlying asset used to calculate the P/L values in this trade
- `number_of_price_steps::Int64=1000`: keyword arg describing the number of steps to take between the start and stop price. Default: 1000
"""
function compute_option_profit_and_loss_at_expiration(assetSet::Set{PSAbstractAsset}, assetPriceStart::Float64, assetPriceStop::Float64; 
    number_of_price_steps::Int64=1000)::(Union{PooksoftBase.PSResult{T}, Nothing} where T<:Any)

    # TODO: error checks -

    # setup price range -
    asset_price_array = collect(range(assetPriceStart, assetPriceStop,length=number_of_price_steps))
    
    # return -
    return compute_option_profit_and_loss_at_expiration(assetSet,asset_price_array)
end

"""
    compute_option_profit_and_loss_at_expiration(assetSet::Set{PSAbstractAsset}, underlyingPriceRange::Tuple{Float64,Float64,Int64})::(Union{PooksoftBase.PSResult{T}, Nothing} where T<:Any)

Compute the overall profit and loss (P/L) for a set option contracts with the same expiration date, and underlying asset.

# Arguments 
- `assetSet::Set{PSAbstractAsset}`: A set containing the put and call contract models in this trade. 
- `underlyingPriceRange::Tuple{Float64,Float64,Int64}`: A tuple containing the price start, price stop and number of steps between the start and stop price to be used in the P/L calculation for this trade 
"""
function compute_option_profit_and_loss_at_expiration(assetSet::Set{PSAbstractAsset}, underlyingPriceRange::Tuple{Float64,Float64,Int64})::(Union{PooksoftBase.PSResult{T}, Nothing} where T<:Any)

    # TODO: error checks -

    # setup price range -
    asset_price_array = collect(range(underlyingPriceRange[1], underlyingPriceRange[2],length=underlyingPriceRange[3]))
    
    # return -
    return compute_option_profit_and_loss_at_expiration(assetSet,asset_price_array)
end
# ----------------------------------------------------------------------------------------------------------- #