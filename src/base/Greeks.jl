# Parameters -
# baseAssetPrice::Float64
# volatility::Float64
# timeToExercise::Float64
# numberOfLevels::Float64
# strikePrice::Float64
# riskFreeRate::Float64
# dividendRate::Float64

function delta(parameters::PSOptionKitPricingParameters; modelTreeType::Symbol = :binary, optionContractType::Symbol = :call, earlyExercise::Bool = false)::Float64

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

function theta(parameters::PSOptionKitPricingParameters; modelTreeType::Symbol = :binary, optionContractType::Symbol = :call, earlyExercise::Bool = false)::Float64
    
    # check -
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

function gamma()::Float64
end

function vega()::Float64
end

function rho()::Float64
end