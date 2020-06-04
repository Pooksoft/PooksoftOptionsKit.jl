function compute_call_option_profit_loss_at_expiration(sense::Symbol, strikePrice::Float64, premiumValue::Float64, assetPriceStart::Float64, assetPriceStop::Float64; 
    number_of_price_steps::Int64 = 1000, number_of_contracts::Int64 = 1)::(Union{PSResult{T}, Nothing} where T<:Any)

    # checks -
    if (is_sense_legit(sense) == false)
        throw(error("Ooops! The sense arguement must be either :buy or :sell. We've got: :$(sense)"))
    end

    if (is_postive_value(strikePrice) == false)
        throw(error("Ooops! The strike price must be a positive value."))
    end

    if (is_postive_value(premiumValue) == false)
        throw(error("Ooops! The premimum value must be a positive value."))
    end

    if (is_postive_value(assetPriceStart) == false)
        throw(error("Ooops! The starting asset price must be a positive value."))
    end

    if (is_postive_value(assetPriceStop) == false)
        throw(error("Ooops! The ending asset price must be a positive value."))
    end

    if (is_postive_value(number_of_price_steps) == false)
        throw(error("Ooops! The number of price steps must be a positive value."))
    end

    if (is_postive_value(number_of_price_steps) == false)
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
            profit_loss_array[index,2] = 100.0*(number_of_contracts)*payoffValue
            profit_loss_array[index,3] = 100.0*(number_of_contracts)*profitLossValue

        elseif (sense == :sell)
            
            # compute the P/L -
            payoffValue = min(0.0,-1.0*(priceValue - strikePrice))
            profitLossValue = (payoffValue + premiumValue) 
            
            # cache -
            profit_loss_array[index,1] = priceValue
            profit_loss_array[index,2] = 100.0*(number_of_contracts)*payoffValue
            profit_loss_array[index,3] = 100.0*(number_of_contracts)*profitLossValue
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

    if (is_postive_value(strikePrice) == false)
        throw(error("Ooops! The strike price must be a positive value."))
    end

    if (is_postive_value(premiumValue) == false)
        throw(error("Ooops! The premimum value must be a positive value."))
    end

    if (is_postive_value(assetPriceStart) == false)
        throw(error("Ooops! The starting asset price must be a positive value."))
    end

    if (is_postive_value(assetPriceStop) == false)
        throw(error("Ooops! The ending asset price must be a positive value."))
    end

    if (is_postive_value(number_of_price_steps) == false)
        throw(error("Ooops! The number of price steps must be a positive value."))
    end

    if (is_postive_value(number_of_price_steps) == false)
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
            profit_loss_array[index,2] = 100.0*(number_of_contracts)*payoffValue
            profit_loss_array[index,3] = 100.0*(number_of_contracts)*profitLossValue

        elseif (sense == :sell)
            
            # compute the P/L -
            payoffValue = min(0.0,-1.0*(strikePrice - priceValue))
            profitLossValue = (payoffValue + premiumValue) 
            
            # cache -
            profit_loss_array[index,1] = priceValue
            profit_loss_array[index,2] = 100.0*(number_of_contracts)*payoffValue
            profit_loss_array[index,3] = 100.0*(number_of_contracts)*profitLossValue
        end
    end

    # return -
    return PSResult{Array{Float64,2}}(profit_loss_array)
end

function compute_call_option_profit_loss_at_expiration(optionContract::PSCallOptionContract, assetPriceStart::Float64, assetPriceStop::Float64; 
    number_of_price_steps::Int64=1000, number_of_contracts::Int64=1)::(Union{PSResult{T}, Nothing} where T<:Any)

    # get data from optionContract -
    sense = optionContract.sense
    strikePrice = optionContract.strikePrice
    premiumValue = optionContract.premimumValue

    # call -
    return compute_call_option_profit_loss_at_expiration(sense,strikePrice,premiumValue,assetPriceStart,assetPriceStop; 
        number_of_price_steps=number_of_price_steps,number_of_contracts=number_of_contracts)
end

function compute_put_option_profit_loss_at_expiration(optionContract::PSPutOptionContract, assetPriceStart::Float64, assetPriceStop::Float64; 
    number_of_price_steps::Int64=1000, number_of_contracts::Int64=1)::(Union{PSResult{T}, Nothing} where T<:Any)

    # get data from optionContract -
    sense = optionContract.sense
    strikePrice = optionContract.strikePrice
    premiumValue = optionContract.premimumValue

    # call -
    return compute_put_option_profit_loss_at_expiration(sense,strikePrice, premiumValue, assetPriceStart, assetPriceStop; 
        number_of_price_steps=number_of_price_steps,number_of_contracts=number_of_contracts)
end