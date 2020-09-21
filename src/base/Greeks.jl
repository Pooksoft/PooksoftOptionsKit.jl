# Parameters -
# baseAssetPrice::Float64
# volatility::Float64
# timeToExercise::Float64
# numberOfLevels::Float64
# strikePrice::Float64
# riskFreeRate::Float64
# dividendRate::Float64

function delta(assetSet::Set{PSAbstractAsset}, parameters::PSBinaryLatticeModel, underlyingAssetPrice::Float64; 
    earlyExercise::Bool = false)::PSResult

    # TODO: checks ...
    # check - asset price > 0
    if (underlyingAssetPrice <= zero(underlyingAssetPrice))
        return (PSResult(ArgumentError("Underlying asset price must be positive")))
    end
    
    # base - we are looking at how the options price changes with $1 increase in the underlying -
    result = option_contract_price(assetSet,parameters,underlyingAssetPrice; earlyExercise=earlyExercise)
    if (isa(result.value,Exception) == true)
        return result
    end
    results_tuple = result.value;
    base_option_price = first(results_tuple.cost_calculation_result.option_contract_price_array);

    # perturbed - what is the price if the underlying increases by $1 -
    result = option_contract_price(assetSet,parameters,(underlyingAssetPrice + 1.0); earlyExercise=earlyExercise)
    if (isa(result.value,Exception) == true)
        return result
    end
    results_tuple = result.value;
    perturbed_option_price = first(results_tuple.cost_calculation_result.option_contract_price_array);

    # compute delta -
    delta = perturbed_option_price - base_option_price

    # return -
    return PSResult(delta)

end

function theta(assetSet::Set{PSAbstractAsset}, parameters::PSOptionKitPricingParameters, underlyingAssetPrice::Float64; 
    earlyExercise::Bool = false)::PSResult
    
    # TODO: checks ...
    # check - asset price > 0
    if (underlyingAssetPrice <= zero(underlyingAssetPrice))
        return (PSResult(ArgumentError("Underlying asset price must be positive")))
    end
    
    # base - we are looking at how the options price changes with $1 increase in the underlying -
    result = option_contract_price(assetSet,parameters,underlyingAssetPrice; earlyExercise=earlyExercise)
    if (isa(result.value,Exception) == true)
        return result
    end
    results_tuple = result.value;
    base_option_price = first(results_tuple.cost_calculation_result.option_contract_price_array);

    # create a new parameters w/one less day -
    perturbedParameters = deepcopy(parameters)
    perturbedParameters.timeToExercise = (parameters.timeToExercise - 1.0)

    # perturbed - we are looking at how the options price changes with $1 increase in the underlying -
    result = option_contract_price(assetSet, perturbedParameters, underlyingAssetPrice; earlyExercise=earlyExercise)
    if (isa(result.value,Exception) == true)
        return result
    end
    results_tuple = result.value;
    perturbed_option_price = first(results_tuple.cost_calculation_result.option_contract_price_array);

    # compute theta -
    theta = perturbed_option_price - base_option_price

    # return -
    return PSResult(theta)
end

function gamma(assetSet::Set{PSAbstractAsset}, parameters::PSOptionKitPricingParameters, underlyingAssetPrice::Float64; 
    earlyExercise::Bool = false)::PSResult

    # TODO: checks -

    # check - asset price > 0
    if (underlyingAssetPrice <= zero(underlyingAssetPrice))
        return (PSResult(ArgumentError("Underlying asset price must be positive")))
    end

    # compute a base delta -
    base_delta = delta(assetSet,parameters, underlyingAssetPrice; earlyExercise=earlyExercise)

    # compute an updated delta -
    perturbed_delta = delta(assetSet, parameters, (underlyingAssetPrice + 1.0); earlyExercise=earlyExercise)

    # diff -
    gamma = (perturbed_delta - base_delta)

    # compute the difference and return -
    return PSResult(gamma)
end

function vega(assetSet::Set{PSAbstractAsset}, parameters::PSOptionKitPricingParameters, underlyingAssetPrice::Float64; 
    earlyExercise::Bool = false)::PSResult

    # TODO: checks ...
    if (underlyingAssetPrice <= zero(underlyingAssetPrice))
        return (PSResult(ArgumentError("Underlying asset price must be positive")))
    end
    
    # base - we are looking at how the options price changes with $1 increase in the underlying -
    result = option_contract_price(assetSet,parameters,underlyingAssetPrice; earlyExercise=earlyExercise)
    if (isa(result.value,Exception) == true)
        return result
    end
    results_tuple = result.value;
    base_option_price = first(results_tuple.cost_calculation_result.option_contract_price_array);

    # create a new parameters w/increased volatility -
    epsilon = 0.01
    baseVolatility = parameters.volatility
    perturbedParameters = deepcopy(parameters)
    perturbedParameters.volatility = baseVolatility*(1.0+epsilon)

    # perturbed - we are looking at how the options price changes with $1 increase in the underlying -
    result = option_contract_price(assetSet, perturbedParameters, underlyingAssetPrice; earlyExercise=earlyExercise)
    if (isa(result.value,Exception) == true)
        return result
    end
    results_tuple = result.value;
    perturbed_option_price = first(results_tuple.cost_calculation_result.option_contract_price_array);

    # compute theta -
    vega = perturbed_option_price - base_option_price

    # return -
    return PSResult(vega)
end

function rho(assetSet::Set{PSAbstractAsset}, parameters::PSOptionKitPricingParameters, underlyingAssetPrice::Float64; 
    modelTreeType::Symbol = :binary, earlyExercise::Bool = false)::PSResult

    # TODO: checks ...
    # check - asset price > 0
    if (underlyingAssetPrice <= zero(underlyingAssetPrice))
        return (PSResult(ArgumentError("Underlying asset price must be positive")))
    end
    
    # base - we are looking at how the options price changes with $1 increase in the underlying -
    result = option_contract_price(assetSet,parameters,underlyingAssetPrice; earlyExercise=earlyExercise)
    if (isa(result.value,Exception) == true)
        return result
    end
    results_tuple = result.value;
    base_option_price = first(results_tuple.cost_calculation_result.option_contract_price_array);
    
    # create a new parameters w/one less day -
    epsilon = 0.01
    baseRiskFreeRate = parameters.riskFreeRate
    perturbedParameters = deepcopy(parameters)
    perturbedParameters.riskFreeRate = baseRiskFreeRate*(1.0+epsilon)

    # perturbed - we are looking at how the options price changes with $1 increase in the underlying -
    result = option_contract_price(assetSet, perturbedParameters, underlyingAssetPrice; earlyExercise=earlyExercise)
    if (isa(result.value,Exception) == true)
        return result
    end
    results_tuple = result.value;
    perturbed_option_price = first(results_tuple.cost_calculation_result.option_contract_price_array);

    # compute -
    rho = perturbed_option_price - base_option_price

    # return -
    return PSResult(rho)
end