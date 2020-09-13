function intrinsic_value(contract::PSCallOptionContract, currentPriceValue::Float64)::PSResult

    # initialize -
    iv = 0.0
    pl = 0.0
    
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
        iv = (contract_multiplier)*(number_of_contracts)*payoffValue
        pl = (contract_multiplier)*(number_of_contracts)*profitLossValue

    elseif (sense == :sell)
        
        # compute the P/L -
        payoffValue = min(0.0,-1.0*(currentPriceValue - strikePrice))
        profitLossValue = (payoffValue + premiumValue) 
        
        # compute the intrinsic value -
        iv = (contract_multiplier)*(number_of_contracts)*payoffValue
        pl = (contract_multiplier)*(number_of_contracts)*profitLossValue
    end

    # make a named tuple -
    named_tuple = (intrinsic_value=iv,payoff_value=pl)

    # return -
    return PSResult(named_tuple)
end

function intrinsic_value(contract::PSPutOptionContract, currentPriceValue::Float64)::PSResult

    # initialize -
    iv = 0.0
    pl = 0.0
    
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
        pv = (contract_multiplier)*(number_of_contracts)*profitLossValue
        iv = (contract_multiplier)*(number_of_contracts)*payoffValue

    elseif (sense == :sell)

        # compute the P/L -
        payoffValue = min(0.0,-1.0*(strikePrice - currentPriceValue))
        profitLossValue = (payoffValue + premiumValue)

        # compute the intrinsic value -
        pv = (contract_multiplier)*(number_of_contracts)*profitLossValue
        iv = (contract_multiplier)*(number_of_contracts)*payoffValue
    end
    
    # make a named tuple -
    named_tuple = (intrinsic_value=iv,payoff_value=pl)

    # return -
    return PSResult(named_tuple)
end

function intrinsic_value(equityObject::PSEquityAsset, currentPriceValue::Float64)::PSResult

    # initialize -
    iv = 0.0
    pl = 0.0
    
    # get data from equityObject -
    purchasePricePerShare = equityObject.purchasePricePerShare
    numberOfShares = equityObject.numberOfShares

    # compute the intrinsic value -
    iv = numberOfShares*(currentPriceValue - purchasePricePerShare)

    # make a named tuple -
    named_tuple = (intrinsic_value=iv,payoff_value=iv)

    # return -
    return PSResult(named_tuple)
end