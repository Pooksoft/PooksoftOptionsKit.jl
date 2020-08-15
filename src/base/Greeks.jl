# Parameters -
# baseAssetPrice::Float64
# volatility::Float64
# timeToExercise::Float64
# numberOfLevels::Float64
# strikePrice::Float64
# riskFreeRate::Float64
# dividendRate::Float64

function delta(assetSet::Set{PSAbstractAsset}, parameters::PSOptionKitPricingParameters, underlyingAssetPrice::Float64; 
    modelTreeType::Symbol = :binary, earlyExercise::Bool = false)::Float64

    # TODO: checks ...
    
    # check: tree type -
    tree_type_set = Set{Symbol}()
    push!(tree_type_set,:binary)
    push!(tree_type_set,:ternary)
    if (in(modelTreeType,tree_type_set) == false)
        return PSResult(ArgumentError("Unsupported model tree type"))
    end

    # compute the price tree w/the underlying price -
    price_tree_1 = nothing
    if modelTreeType == :binary
        price_tree_1 = build_binary_price_tree(assetSet, parameters, underlyingAssetPrice)
    elseif modelTreeType == :ternary
        price_tree_1 = build_ternary_price_tree(assetSet, parameters, underlyingAssetPrice)        
    end

    # compute the price tree w/(underlyingAssetPrice + 1)
    price_tree_2 = nothing
    if modelTreeType == :binary
        price_tree_2 = build_binary_price_tree(assetSet, parameters, (underlyingAssetPrice + 1.0))
    elseif modelTreeType == :ternary
        price_tree_2 = build_ternary_price_tree(assetSet, parameters, (underlyingAssetPrice + 1.0))
    end

    # compute the option cost w/price_tree_1 -
    option_price_1 = nothing
    result = option_contract_price(price_tree_1, parameters)
    if (typeof(result.value) == PSError)
        return result
    else
        option_price_1 = result.value
    end

    # compute the option cosr w/price_tree_2
    option_price_2 = nothing
    result = option_contract_price(price_tree_2, parameters)
    if (typeof(result.value) == PSError)
        return result
    else
        option_price_2 = result.value
    end

    # compute delta -
    delta = option_price_2 - option_price_1

    # return -
    return delta
end

function theta(assetSet::Set{PSAbstractAsset}, parameters::PSOptionKitPricingParameters, underlyingAssetPrice::Float64; 
    modelTreeType::Symbol = :binary, earlyExercise::Bool = false)::Float64
    
    # TODO: checks ...
    
    # check: tree type -
    tree_type_set = Set{Symbol}()
    push!(tree_type_set,:binary)
    push!(tree_type_set,:ternary)
    if (in(modelTreeType,tree_type_set) == false)
        return PSResult(ArgumentError("Unsupported model tree type"))
    end

    # compute the price tree w/the underlying price -
    price_tree_1 = nothing
    if modelTreeType == :binary
        price_tree_1 = build_binary_price_tree(assetSet, parameters, underlyingAssetPrice)
    elseif modelTreeType == :ternary
        price_tree_1 = build_ternary_price_tree(assetSet, parameters, underlyingAssetPrice)        
    end

    # create a new parameters w/one less day -
    perturbedParameters = deepcopy(parameters)
    perturbedParameters = (perturbedParameters.timeToExercise - (1.0/365.0))

    # compute the price tree w/the updated time to excercise -
    price_tree_2 = nothing
    if modelTreeType == :binary
        price_tree_2 = build_binary_price_tree(assetSet, perturbedParameters, underlyingAssetPrice)
    elseif modelTreeType == :ternary
        price_tree_2 = build_ternary_price_tree(assetSet, perturbedParameters, underlyingAssetPrice)        
    end

    # compute the option cost w/price_tree_1 -
    option_price_1 = nothing
    result = option_contract_price(price_tree_1, parameters)
    if (typeof(result.value) == PSError)
        return result
    else
        option_price_1 = result.value
    end

    # compute the option cosr w/price_tree_2
    option_price_2 = nothing
    result = option_contract_price(price_tree_2, perturbedParameters)
    if (typeof(result.value) == PSError)
        return result
    else
        option_price_2 = result.value
    end

    # compute theta -
    theta = option_price_2 - option_price_1

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