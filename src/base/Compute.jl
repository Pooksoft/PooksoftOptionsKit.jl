function compute_call_option_profit_loss_at_expiration(sense::Symbol, strikePrice::Float64, premiumValue::Float64, assetPriceStart::Float64, assetPriceStop::Float64; 
    number_of_price_steps::Int64 = 1000, number_of_contracts::Int64 = 1)::(Union{PSResult{T}, Nothing} where T<:Any)

    # checks -
    if (is_sense_legit(sense) == false)
        throw(error("Ooops! The sense arguement must be either :buy or :sell. We've got: :$(sense)"))
    end

    if (is_positive_value(strikePrice) == false)
        throw(error("Ooops! The strike price must be a positive value."))
    end

    if (is_positive_value(premiumValue) == false)
        throw(error("Ooops! The premimum value must be a positive value."))
    end

    if (is_positive_value(assetPriceStart) == false)
        throw(error("Ooops! The starting asset price must be a positive value."))
    end

    if (is_positive_value(assetPriceStop) == false)
        throw(error("Ooops! The ending asset price must be a positive value."))
    end

    if (is_positive_value(number_of_price_steps) == false)
        throw(error("Ooops! The number of price steps must be a positive value."))
    end

    if (is_positive_value(number_of_contracts) == false)
        throw(error("Ooops! The number of contracts must be a positive value."))
    end

    # initialize -
    profit_loss_array = zeros(number_of_price_steps,3)

    # setup price range -
    asset_price_range = collect(range(assetPriceStart, assetPriceStop,length=number_of_price_steps))
    for (index, priceValue) in enumerate(asset_price_range)
        
        if (sense == :buy)
            
            # compute the P/L -
            payoffValue = max(0.0, (priceValue - strikePrice))
            profitLossValue = (payoffValue - premiumValue) 
            
            # cache -
            profit_loss_array[index,1] = priceValue
            profit_loss_array[index,3] = 100.0*(number_of_contracts)*payoffValue
            profit_loss_array[index,2] = 100.0*(number_of_contracts)*profitLossValue

        elseif (sense == :sell)
            
            # compute the P/L -
            payoffValue = min(0.0,-1.0*(priceValue - strikePrice))
            profitLossValue = (payoffValue + premiumValue) 
            
            # cache -
            profit_loss_array[index,1] = priceValue
            profit_loss_array[index,3] = 100.0*(number_of_contracts)*payoffValue
            profit_loss_array[index,2] = 100.0*(number_of_contracts)*profitLossValue
        end
    end

    # return -
    return PSResult{Array{Float64,2}}(profit_loss_array)
end

function compute_put_option_profit_loss_at_expiration(sense::Symbol, strikePrice::Float64, premiumValue::Float64, assetPriceStart::Float64, assetPriceStop::Float64; 
    number_of_price_steps::Int64 = 1000, number_of_contracts::Int64 = 1)::(Union{PSResult{T}, Nothing} where T<:Any)

    # checks -
    if (is_sense_legit(sense) == false)
        throw(error("Ooops! The sense arguement must be either :buy or :sell. We've got: :$(sense)"))
    end

    if (is_positive_value(strikePrice) == false)
        throw(error("Ooops! The strike price must be a positive value."))
    end

    if (is_positive_value(premiumValue) == false)
        throw(error("Ooops! The premimum value must be a positive value."))
    end

    if (is_positive_value(assetPriceStart) == false)
        throw(error("Ooops! The starting asset price must be a positive value."))
    end

    if (is_positive_value(assetPriceStop) == false)
        throw(error("Ooops! The ending asset price must be a positive value."))
    end

    if (is_positive_value(number_of_price_steps) == false)
        throw(error("Ooops! The number of price steps must be a positive value."))
    end

    if (is_positive_value(number_of_contracts) == false)
        throw(error("Ooops! The number of contracts must be a positive value."))
    end

    # initialize -
    profit_loss_array = zeros(number_of_price_steps,3)

    # setup price range -
    asset_price_range = collect(range(assetPriceStart, assetPriceStop,length=number_of_price_steps))
    for (index, priceValue) in enumerate(asset_price_range)
        
        if (sense == :buy)
            
            # compute the P/L -
            payoffValue = max(0.0, (strikePrice - priceValue))
            profitLossValue = (payoffValue - premiumValue) 
            
            # cache -
            profit_loss_array[index,1] = priceValue
            profit_loss_array[index,3] = 100.0*(number_of_contracts)*payoffValue
            profit_loss_array[index,2] = 100.0*(number_of_contracts)*profitLossValue

        elseif (sense == :sell)
            
            # compute the P/L -
            payoffValue = min(0.0,-1.0*(strikePrice - priceValue))
            profitLossValue = (payoffValue + premiumValue) 
            
            # cache -
            profit_loss_array[index,1] = priceValue
            profit_loss_array[index,3] = 100.0*(number_of_contracts)*payoffValue
            profit_loss_array[index,2] = 100.0*(number_of_contracts)*profitLossValue
        end
    end

    # return -
    return PSResult{Array{Float64,2}}(profit_loss_array)
end

function compute_call_option_profit_loss_at_expiration(optionContract::PSCallOptionContract, assetPriceStart::Float64, assetPriceStop::Float64; 
    number_of_price_steps::Int64=1000)::(Union{PSResult{T}, Nothing} where T<:Any)

    # get data from optionContract -
    sense = optionContract.sense
    strikePrice = optionContract.strikePrice
    premiumValue = optionContract.premimumValue
    number_of_contracts = optionContract.numberOfContracts

    # call -
    return compute_call_option_profit_loss_at_expiration(sense,strikePrice,premiumValue,assetPriceStart,assetPriceStop; 
        number_of_price_steps=number_of_price_steps,number_of_contracts=number_of_contracts)
end

function compute_put_option_profit_loss_at_expiration(optionContract::PSPutOptionContract, assetPriceStart::Float64, assetPriceStop::Float64; 
    number_of_price_steps::Int64=1000)::(Union{PSResult{T}, Nothing} where T<:Any)

    # get data from optionContract -
    sense = optionContract.sense
    strikePrice = optionContract.strikePrice
    premiumValue = optionContract.premimumValue
    number_of_contracts = optionContract.numberOfContracts

    # call -
    return compute_put_option_profit_loss_at_expiration(sense,strikePrice, premiumValue, assetPriceStart, assetPriceStop; 
        number_of_price_steps=number_of_price_steps,number_of_contracts=number_of_contracts)
end

function compute_equity_asset_profit_loss_at_expiration(equityObject::PSEquityAsset, assetPriceStart::Float64, assetPriceStop::Float64; 
    number_of_price_steps::Int64=1000)::(Union{PSResult{T}, Nothing} where T<:Any)

    # initialize -
    assetProfitLossArray = zeros(number_of_price_steps,2)

    # get data from equityObject -
    purchasePricePerShare = equityObject.purchasePricePerShare
    numberOfShares = equityObject.numberOfShares

    # setup price range -
    asset_price_range = collect(range(assetPriceStart, assetPriceStop,length=number_of_price_steps))
    for (index, priceValue) in enumerate(asset_price_range)
        
        # compute the P and L -
        tmpValue = numberOfShares*(priceValue - purchasePricePerShare)
        
        # capture -
        assetProfitLossArray[index,1] = priceValue
        assetProfitLossArray[index,2] = tmpValue
    end    

    # return -
    return PSResult{Array{Float64,2}}(assetProfitLossArray)
end

function compute_complex_trade_profit_and_loss_at_expiration(assetSet::Set{PSAbstractAsset}, assetPriceStart::Float64, assetPriceStop::Float64; 
    number_of_price_steps::Int64=1000)::(Union{PSResult{T}, Nothing} where T<:Any)

    # checks -
    # ...

    # initialize -
    number_of_assets = length(assetSet)
    assetProfitLossArray = zeros(number_of_price_steps,number_of_assets)
    tradeProfitLossArray = zeros(number_of_price_steps,2) # firstCol: price, secondCol: PL

    # process the set of assets -
    assetIndex = 1
    while (isempty(assetSet) == false)
        
        # grab an asset -
        assetObject = pop!(assetSet)

        # process each asset type -
        result = nothing
        if (typeof(assetObject) == PSCallOptionContract)
            
            # compute the PL for the call option -
            result = compute_call_option_profit_loss_at_expiration(assetObject,assetPriceStart,assetPriceStop; number_of_price_steps=number_of_price_steps)
        elseif (typeof(assetObject) == PSPutOptionContract)

            # compute the PL for the put option -
            result = compute_put_option_profit_loss_at_expiration(assetObject, assetPriceStart,assetPriceStop; number_of_price_steps=number_of_price_steps)
        elseif (typeof(assetObject) == PSEquityAsset)

            # compute the PL for the stock -
            result = compute_equity_asset_profit_loss_at_expiration(assetObject, assetPriceStart, assetPriceStop; number_of_price_steps=number_of_price_steps)
        
        else
            
            # return an error object -
            errorObject = PSError("Ooops! Asset type is not supported. Expected PSCallOptionContract, PSPutOptionContract, PSEquityAsset. Got $(assetObject)")
            return PSResult{PSError}(errorObject)
        end 
        
        if result !== nothing
                
            if (typeof(result.value) == PSError)
                # error -
                return PSResult{PSError}(result.value)
            else

                # we will have the PL array -> 2nd col is the PL
                tmpArray = result.value
                for index = 1:number_of_price_steps
                    assetProfitLossArray[index,assetIndex] = tmpArray[index,2]
                end
            end            
        else
            # error - 
            errorObject = PSError("Ooops! Asset profit and loss calculation returned nothing object.")
            return PSResult{PSError}(errorObject)
        end
    
        # update assetIndex -
        assetIndex = assetIndex + 1
    end

    # ok, so the assetProfitLossArray holds the PL for each asset type in its cols -
    # to get the PL for the entire trade at a particular stock price, then sum across the cols -
    asset_price_range = collect(range(assetPriceStart, assetPriceStop,length=number_of_price_steps))
    for price_index = 1:number_of_price_steps
        
        # grab col -
        tmp_row = assetProfitLossArray[price_index,:]
    
        # add - 
        tradeProfitLossArray[price_index,1] = asset_price_range[price_index]
        tradeProfitLossArray[price_index,2] = sum(tmp_row)
    end

    # return -
    return PSResult{Array{Float64,2}}(tradeProfitLossArray)
end