# -- PRIVATE FUNCTIONS ------------------------------------------- #
function _iv_objective_function(x, assetSet::Set{PSAbstractAsset}, parameters::PSOptionKitPricingParameters, baseAssetPriceValue::Float64, optionPriceValue::Float64)

    # create a new paramter w/new volatility -
    perturbedVolatility = x[1]
    perturbedParameters = PSOptionKitPricingParameters(perturbedVolatility, parameters.timeToExercise, parameters.numberOfLevels,
        parameters.riskFreeRate, parameters.dividendRate)

    # build the pricing tree -
    tree = build_binary_price_tree(assetSet, perturbedParameters, baseAssetPriceValue)

    # re-compute the option price -
    result = option_contract_price(tree, perturbedParameters)

    # get the estimated value -
    estimatedPriceValue = result.value

    @show (perturbedVolatility, estimatedPriceValue, baseAssetPriceValue, optionPriceValue)

    # compute the error -
    error_term = (optionPriceValue - estimatedPriceValue)

    # return -
    return error_term*error_term    
end
# ---------------------------------------------------------------- #

# -- PUBLIC FUNCTIONS -------------------------------------------- #
function estimate_implied_volatility(contract::PSAbstractAsset, parameters::PSOptionKitPricingParameters, baseAssetPriceValue::Float64; 
    earlyExercise::Bool = false)

    # setup asset set -
    assetSet = Set{PSAbstractAsset}()
    push!(assetSet, contract)

    # what is the premium?
    optionPriceValue = contract.premimumValue

    # what is the initial volatility -
    initialVolatility = [parameters.volatility]
    
    # setup the objective function -
    OF(p) = _iv_objective_function(p, assetSet, parameters, baseAssetPriceValue, optionPriceValue)

    # call the optimizer -
    opt_result = Optim.optimize(OF, initialVolatility, BFGS())

    # return the result -
    return Optim.minimizer(opt_result)[1]
end
# ---------------------------------------------------------------- #