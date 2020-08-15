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

    # check - asset price > 0
    if (underlyingAssetPrice <= zero(underlyingAssetPrice))
        return (PSResult(ArgumentError("Underlying asset price must be positive")))
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

    # check - asset price > 0
    if (underlyingAssetPrice <= zero(underlyingAssetPrice))
        return (PSResult(ArgumentError("Underlying asset price must be positive")))
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
    perturbedParameters.timeToExercise = (parameters.timeToExercise - (1.0/365.0))

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

    # compute the option cost w/price_tree_2
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

function gamma(assetSet::Set{PSAbstractAsset}, parameters::PSOptionKitPricingParameters, underlyingAssetPrice::Float64; earlyExercise::Bool = false)::Float64

    # TODO: checks -

    # check: tree type -
    tree_type_set = Set{Symbol}()
    push!(tree_type_set,:binary)
    push!(tree_type_set,:ternary)
    if (in(modelTreeType,tree_type_set) == false)
        return PSResult(ArgumentError("Unsupported model tree type"))
    end

    # check - asset price > 0
    if (underlyingAssetPrice <= zero(underlyingAssetPrice))
        return (PSResult(ArgumentError("Underlying asset price must be positive")))
    end

    # compute a base delta -
    base_delta = delta(assetSet,parameters,underlyingAssetPrice; earlyExercise=earlyExercise)

    # compute an updated delta -
    perturbed_delta = delta(assetSet, parameters, (underlyingAssetPrice + 1.0); earlyExercise=earlyExercise)

    # compute the difference and return -
    return (perturbed_delta - base_delta)
end

function vega(assetSet::Set{PSAbstractAsset}, parameters::PSOptionKitPricingParameters, underlyingAssetPrice::Float64; earlyExercise::Bool = false)::Float64

    # TODO: checks ...
    
    # check: tree type -
    tree_type_set = Set{Symbol}()
    push!(tree_type_set,:binary)
    push!(tree_type_set,:ternary)
    if (in(modelTreeType,tree_type_set) == false)
        return PSResult(ArgumentError("Unsupported model tree type"))
    end

    # check - asset price > 0
    if (underlyingAssetPrice <= zero(underlyingAssetPrice))
        return (PSResult(ArgumentError("Underlying asset price must be positive")))
    end
    
    # compute the price tree w/the underlying price -
    price_tree_1 = nothing
    if modelTreeType == :binary
        price_tree_1 = build_binary_price_tree(assetSet, parameters, underlyingAssetPrice)
    elseif modelTreeType == :ternary
        price_tree_1 = build_ternary_price_tree(assetSet, parameters, underlyingAssetPrice)        
    end

    # create a new parameters w/one less day -
    epsilon = 0.01
    baseVolatility = parameters.volatility
    perturbedParameters = deepcopy(parameters)
    perturbedParameters.volatility = baseVolatility*(1.0+epsilon)

    # compute the price tree w/the updated volatility -
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

    # compute the option cost w/price_tree_2
    option_price_2 = nothing
    result = option_contract_price(price_tree_2, perturbedParameters)
    if (typeof(result.value) == PSError)
        return result
    else
        option_price_2 = result.value
    end

    # compute theta -
    vega = option_price_2 - option_price_1

    # return -
    return vega
end

function rho(parameters::PSOptionKitPricingParameters; modelTreeType::Symbol = :binary, 
    optionContractType::Symbol = :call, earlyExercise::Bool = false)::Float64

    # TODO: checks ...
    
    # check: tree type -
    tree_type_set = Set{Symbol}()
    push!(tree_type_set,:binary)
    push!(tree_type_set,:ternary)
    if (in(modelTreeType,tree_type_set) == false)
        return PSResult(ArgumentError("Unsupported model tree type"))
    end

    # check - asset price > 0
    if (underlyingAssetPrice <= zero(underlyingAssetPrice))
        return (PSResult(ArgumentError("Underlying asset price must be positive")))
    end
    
    # compute the price tree w/the underlying price -
    price_tree_1 = nothing
    if modelTreeType == :binary
        price_tree_1 = build_binary_price_tree(assetSet, parameters, underlyingAssetPrice)
    elseif modelTreeType == :ternary
        price_tree_1 = build_ternary_price_tree(assetSet, parameters, underlyingAssetPrice)        
    end
    
    # create a new parameters w/one less day -
    epsilon = 0.01
    baseRiskFreeRate = parameters.riskFreeRate
    perturbedParameters = deepcopy(parameters)
    perturbedParameters.riskFreeRate = baseRiskFreeRate*(1.0+epsilon)

    # compute the price tree w/the updated volatility -
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

    # compute the option cost w/price_tree_2
    option_price_2 = nothing
    result = option_contract_price(price_tree_2, perturbedParameters)
    if (typeof(result.value) == PSError)
        return result
    else
        option_price_2 = result.value
    end

    # compute -
    rho = option_price_2 - option_price_1

    # return -
    return rho
end