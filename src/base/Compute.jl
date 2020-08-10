# --- PRIVATE METHODS --------------------------------------------------------------------------------------- #
function _compute_profit_loss_at_expiration(asset::PSAbstractAsset, assetPriceValueArray::Array{Float64,1})::Array{Float64,1}

    # initialize -
    profit_loss_array = Array{Float64,1}()

    # compute the intrinsic value -
    for (index, asset_price_value) in enumerate(assetPriceValueArray)
        iv = intrinsic_value(asset,asset_price_value)
        push!(profit_loss_array,iv)
    end

    # call -
    return profit_loss_array
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

function compute_option_profit_and_loss_at_expiration(assetSet::Set{PSAbstractAsset}, assetPriceStart::Float64, assetPriceStop::Float64; 
    number_of_price_steps::Int64=1000)::(Union{PSResult{T}, Nothing} where T<:Any)

    # TODO: error checks -

    # setup price range -
    asset_price_array = collect(range(assetPriceStart, assetPriceStop,length=number_of_price_steps))
    
    # return -
    return compute_option_profit_and_loss_at_expiration(assetSet,asset_price_array)
end
# ----------------------------------------------------------------------------------------------------------- #