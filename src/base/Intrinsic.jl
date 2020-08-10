function intrinsic_value(contract::PSCallOptionContract, currentPriceValue::Float64)::Float64

    # initialize -
    iv = 0.0
    
    # get data from the contract object -
    sense = contract.sense
    strikePrice = contract.strikePrice
    premiumValue = contract.premimumValue
    number_of_contracts = contract.numberOfContracts
    contract_multiplier = contract.contractMultiplier

    # compute the iv -
    if (sense == :buy)

        # compute the P/L -
        payoffValue = max(0.0, (currentPriceValue - strikePrice))
        profitLossValue = (payoffValue - premiumValue) 
        
        # compute the intrinsic value -
        iv = (contract_multiplier)*(number_of_contracts)*profitLossValue

    elseif (sense == :sell)
        
        # compute the P/L -
        payoffValue = min(0.0,-1.0*(currentPriceValue - strikePrice))
        profitLossValue = (payoffValue + premiumValue) 
        
        # compute the intrinsic value -
        iv = (contract_multiplier)*(number_of_contracts)*profitLossValue
    end

    # return -
    return iv
end

function intrinsic_value(contract::PSPutOptionContract, currentPriceValue::Float64)::Float64

    # initialize -
    iv = 0.0
    
    # get data from the contract object -
    sense = contract.sense
    strikePrice = contract.strikePrice
    premiumValue = contract.premimumValue
    number_of_contracts = contract.numberOfContracts
    contract_multiplier = contract.contractMultiplier

    # compute the iv -
    if (sense == :buy)

        # compute the P/L -
        payoffValue = max(0.0, (strikePrice - currentPriceValue))
        profitLossValue = (payoffValue - premiumValue) 

        # compute the intrinsic value -
        iv = (contract_multiplier)*(number_of_contracts)*profitLossValue

    elseif (sense == :sell)

        # compute the P/L -
        payoffValue = min(0.0,-1.0*(strikePrice - currentPriceValue))
        profitLossValue = (payoffValue + premiumValue)

        # compute the intrinsic value -
        iv = (contract_multiplier)*(number_of_contracts)*profitLossValue
    end
    
    # return -
    return iv
end

function intrinsic_value(equityObject::PSEquityAsset, currentPriceValue::Float64)::Float64

    # initialize -
    iv = 0.0
    
    # get data from equityObject -
    purchasePricePerShare = equityObject.purchasePricePerShare
    numberOfShares = equityObject.numberOfShares

    # compute the intrinsic value -
    iv = numberOfShares*(currentPriceValue - purchasePricePerShare)

    # return -
    return iv
end