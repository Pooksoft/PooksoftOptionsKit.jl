# Parameters -
# baseAssetPrice::Float64
# volatility::Float64
# timeToExercise::Float64
# numberOfLevels::Float64
# strikePrice::Float64
# riskFreeRate::Float64
# dividendRate::Float64

"""
    delta(assetSet::Set{PSAbstractAsset}, parameters::PSBinaryLatticeModel, underlyingAssetPrice::Float64; 
        earlyExercise::Bool = false)::PSResult

Compute the change in the option price for a 1-dollar increase in the underlying stock price

# Arguments
- `assetSet::Set{PSAbstractAsset}`: A set containing the put and call models involved in this trade. 
- `parameters::PSBinaryLatticeModel`: A PSBinaryLatticeModel object containing the parameters for the lattice
- `underlyingAssetPrice::Float64`: Underlying stock price at the time of purchase of the contract
- `earlyExercise::Bool = false`: Can this option contract be excercised early (true for American options)
"""
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
    result = option_contract_price(assetSet,parameters, (underlyingAssetPrice + 1.0); earlyExercise=earlyExercise)
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

"""
    theta(assetSet::Set{PSAbstractAsset}, parameters::PSBinaryLatticeModel, underlyingAssetPrice::Float64; 
        earlyExercise::Bool = false)::PSResult

Compute the change in the price of the option contract for a one day decrease in the number of days left until expiration

# Arguments
- `assetSet::Set{PSAbstractAsset}`: A set containing the put and call models involved in this trade. 
- `parameters::PSBinaryLatticeModel`: A PSBinaryLatticeModel object containing the parameters for the lattice
- `underlyingAssetPrice::Float64`: Underlying stock price at the time of purchase of the contract
- `earlyExercise::Bool = false`: Can this option contract be excercised early (true for American options)
"""
function theta(assetSet::Set{PSAbstractAsset}, parameters::PSBinaryLatticeModel, underlyingAssetPrice::Float64; 
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

"""
    gamma(assetSet::Set{PSAbstractAsset}, parameters::PSBinaryLatticeModel, underlyingAssetPrice::Float64; 
        earlyExercise::Bool = false)::PSResult

Compute the rate of change of the delta parameter

# Arguments
- `assetSet::Set{PSAbstractAsset}`: A set containing the put and call models involved in this trade. 
- `parameters::PSBinaryLatticeModel`: A PSBinaryLatticeModel object containing the parameters for the lattice
- `underlyingAssetPrice::Float64`: Underlying stock price at the time of purchase of the contract
- `earlyExercise::Bool = false`: Can this option contract be excercised early (true for American options)
"""
function gamma(assetSet::Set{PSAbstractAsset}, parameters::PSBinaryLatticeModel, underlyingAssetPrice::Float64; 
    earlyExercise::Bool = false)::PSResult

    # TODO: checks -

    # check - asset price > 0
    if (underlyingAssetPrice <= zero(underlyingAssetPrice))
        return (PSResult(ArgumentError("Underlying asset price must be positive")))
    end

    # compute a base delta -
    result = delta(assetSet,parameters, underlyingAssetPrice; earlyExercise=earlyExercise)
    if (isa(result.value,Exception) == true)
        return result
    end
    base_delta = result.value;

    # compute an updated delta -
    result = delta(assetSet, parameters, (underlyingAssetPrice + 1.0); earlyExercise=earlyExercise)
    if (isa(result.value,Exception) == true)
        return result
    end
    perturbed_delta = result.value;

    # diff -
    gamma = (perturbed_delta - base_delta)

    # compute the difference and return -
    return PSResult(gamma)
end


"""

    vega(assetSet::Set{PSAbstractAsset}, parameters::PSBinaryLatticeModel, underlyingAssetPrice::Float64; 
        earlyExercise::Bool = false)::PSResult

Compute the change in the price of an option contract for a 1-percent increase in the implied volatility

# Arguments
- `assetSet::Set{PSAbstractAsset}`: A set containing the put and call models involved in this trade. 
- `parameters::PSBinaryLatticeModel`: A PSBinaryLatticeModel object containing the parameters for the lattice
- `underlyingAssetPrice::Float64`: Underlying stock price at the time of purchase of the contract
- `earlyExercise::Bool = false`: Can this option contract be excercised early (true for American options)
"""
function vega(assetSet::Set{PSAbstractAsset}, parameters::PSBinaryLatticeModel, underlyingAssetPrice::Float64; 
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

"""

    rho(assetSet::Set{PSAbstractAsset}, parameters::PSBinaryLatticeModel, underlyingAssetPrice::Float64; 
        earlyExercise::Bool = false)::PSResult

Compute the change in the price of an option contract for a 1% increase in the risk free rate

# Arguments
- `assetSet::Set{PSAbstractAsset}`: A set containing the put and call models involved in this trade. 
- `parameters::PSBinaryLatticeModel`: A PSBinaryLatticeModel object containing the parameters for the lattice
- `underlyingAssetPrice::Float64`: Underlying stock price at the time of purchase of the contract
- `earlyExercise::Bool = false`: Can this option contract be excercised early (true for American options)
"""
function rho(assetSet::Set{PSAbstractAsset}, parameters::PSBinaryLatticeModel, underlyingAssetPrice::Float64; 
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