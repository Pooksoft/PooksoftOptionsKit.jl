# Parameters -
# baseAssetPrice::Float64
# volatility::Float64
# timeToExercise::Float64
# numberOfLevels::Float64
# strikePrice::Float64
# riskFreeRate::Float64
# dividendRate::Float64

function delta(parameters::PSOptionKitPricingParameters; modelTreeType::Symbol = :binary, 
    optionContractType::Symbol = :call, earlyExercise::Bool = false)::Float64

    # TODO: checks ...
    # ...
    
    # compute the option price with the base parameters -
    baseOptionPriceTree = option_contract_price(parameters; modelTreeType = modelTreeType, optionContractType = optionContractType)

    # create a new paramter w + 1 price -
    perturbedParameters = PSOptionKitPricingParameters(((parameters.baseAssetPrice) + 1), parameters.volatility, parameters.timeToExercise, parameters.numberOfLevels,
        parameters.strikePrice, parameters.riskFreeRate, parameters.dividendRate)

    # re-compute the option price -
    perturbedOptionPriceTree = option_contract_price(perturbedParameters; modelTreeType = modelTreeType, optionContractType = optionContractType)

    # compute delta -
    delta = 0.0
    if (earlyExercise == false)
        delta = perturbedOptionPriceTree.root.europeanOptionValue - baseOptionPriceTree.root.europeanOptionValue
    else
        delta = perturbedOptionPriceTree.root.americanOptionValue - baseOptionPriceTree.root.americanOptionValue
    end

    # return -
    return delta
end

function theta(parameters::PSOptionKitPricingParameters; modelTreeType::Symbol = :binary, 
    optionContractType::Symbol = :call, earlyExercise::Bool = false)::Float64
    
    # TODO: checks ...
    # ...
    
    # compute the option price with the base parameters -
    baseOptionPriceTree = option_contract_price(parameters; modelTreeType = modelTreeType, optionContractType = optionContractType)

    # create a new paramter w + 1 price -
    perturbedParameters = PSOptionKitPricingParameters(parameters.baseAssetPrice, parameters.volatility, (parameters.timeToExercise - (1.0/365)), parameters.numberOfLevels,
        parameters.strikePrice, parameters.riskFreeRate, parameters.dividendRate)

    # re-compute the option price -
    perturbedOptionPriceTree = option_contract_price(perturbedParameters; modelTreeType = modelTreeType, optionContractType = optionContractType)

    # compute delta -
    theta = 0.0
    if (earlyExercise == false)
        theta = perturbedOptionPriceTree.root.europeanOptionValue - baseOptionPriceTree.root.europeanOptionValue
    else
        theta = perturbedOptionPriceTree.root.americanOptionValue - baseOptionPriceTree.root.americanOptionValue
    end

    # return -
    return theta
end

function gamma(parameters::PSOptionKitPricingParameters; modelTreeType::Symbol = :binary, 
    optionContractType::Symbol = :call, earlyExercise::Bool = false)::Float64

    # TODO: checks -
    # ...

    # compute base delta -
    baseDelta = delta(parameters; modelTreeType = modelTreeType, optionContractType = optionContractType, earlyExercise = earlyExercise)

    # create a new paramter w + 1 price -
    perturbedParameters = PSOptionKitPricingParameters(((parameters.baseAssetPrice) + 1), parameters.volatility, parameters.timeToExercise, parameters.numberOfLevels,
        parameters.strikePrice, parameters.riskFreeRate, parameters.dividendRate)

    # compute the updated delta -
    perturbedDelta = delta(perturbedParameters; modelTreeType = modelTreeType, optionContractType = optionContractType, earlyExercise = earlyExercise)

    # compute the difference and return -
    return (perturbedDelta - baseDelta)
end

function vega(parameters::PSOptionKitPricingParameters; modelTreeType::Symbol = :binary, 
    optionContractType::Symbol = :call, earlyExercise::Bool = false)::Float64

    # TODO: checks ...
    # ...
    
    # compute the option price with the base parameters -
    baseOptionPriceTree = option_contract_price(parameters; modelTreeType = modelTreeType, optionContractType = optionContractType)

    # create a new paramter w/(1+eps)*baseRiskFreeRate -
    epsilon = 0.01
    baseVolatility = parameters.volatility
    perturbedVolatility = baseVolatility*(1 + epsilon)
    perturbedParameters = PSOptionKitPricingParameters(parameters.baseAssetPrice, perturbedVolatility, parameters.timeToExercise, parameters.numberOfLevels,
        parameters.strikePrice, parameters.riskFreeRate, parameters.dividendRate)

    # re-compute the option price -
    perturbedOptionPriceTree = option_contract_price(perturbedParameters; modelTreeType = modelTreeType, optionContractType = optionContractType)

    # compute delta -
    vega = 0.0
    if (earlyExercise == false)
        vega = (perturbedOptionPriceTree.root.europeanOptionValue - baseOptionPriceTree.root.europeanOptionValue)/(baseVolatility*epsilon)
    else
        vega = (perturbedOptionPriceTree.root.americanOptionValue - baseOptionPriceTree.root.americanOptionValue)/(baseVolatility*epsilon)
    end

    # return -
    return vega
end

function rho(parameters::PSOptionKitPricingParameters; modelTreeType::Symbol = :binary, 
    optionContractType::Symbol = :call, earlyExercise::Bool = false)::Float64

    # TODO: checks ...
    # ...
    
    # compute the option price with the base parameters -
    baseOptionPriceTree = option_contract_price(parameters; modelTreeType = modelTreeType, optionContractType = optionContractType)

    # create a new paramter w/(1+eps)*baseRiskFreeRate -
    epsilon = 0.01
    baseRiskFreeRate = parameters.riskFreeRate
    perturbedRiskFreeRate = baseRiskFreeRate*(1 + epsilon)
    perturbedParameters = PSOptionKitPricingParameters(parameters.baseAssetPrice, parameters.volatility, parameters.timeToExercise, parameters.numberOfLevels,
        parameters.strikePrice, perturbedRiskFreeRate, parameters.dividendRate)

    # re-compute the option price -
    perturbedOptionPriceTree = option_contract_price(perturbedParameters; modelTreeType = modelTreeType, optionContractType = optionContractType)

    # compute delta -
    rho = 0.0
    if (earlyExercise == false)
        rho = (perturbedOptionPriceTree.root.europeanOptionValue - baseOptionPriceTree.root.europeanOptionValue)/(baseRiskFreeRate*epsilon)
    else
        rho = (perturbedOptionPriceTree.root.americanOptionValue - baseOptionPriceTree.root.americanOptionValue)/(baseRiskFreeRate*epsilon)
    end

    # return -
    return rho
end