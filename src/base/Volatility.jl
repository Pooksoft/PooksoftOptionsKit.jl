# -- PRIVATE FUNCTIONS ------------------------------------------- #
function _iv_objective_function(x, priceValue::Float64, parameters::PSOptionKitPricingParameters; modelTreeType::Symbol = :binary, 
    optionContractType::Symbol = :call, earlyExercise::Bool = false)

    # create a new paramter w/new volatility -
    perturbedVolatility = x[1]
    perturbedParameters = PSOptionKitPricingParameters(parameters.baseAssetPrice, perturbedVolatility, parameters.timeToExercise, parameters.numberOfLevels,
        parameters.strikePrice, parameters.riskFreeRate, parameters.dividendRate)

    # re-compute the option price -
    perturbedOptionPriceTree = option_contract_price(perturbedParameters; modelTreeType = modelTreeType, optionContractType = optionContractType)

    # get the estimated value -
    estimatedPriceValue = 0.0
    if (earlyExercise == false)
        estimatedPriceValue = perturbedOptionPriceTree.root.europeanOptionValue
    else
        estimatedPriceValue = perturbedOptionPriceTree.root.americanOptionValue
    end

    # compute the error -
    error_term = (priceValue - estimatedPriceValue)

    # return -
    return error_term*error_term
end
# ---------------------------------------------------------------- #

# -- PUBLIC FUNCTIONS -------------------------------------------- #
function estimate_implied_volatility(optionPriceValue::Float64, parameters::PSOptionKitPricingParameters; modelTreeType::Symbol = :binary, 
    optionContractType::Symbol = :call, earlyExercise::Bool = false)

    # what is the initial volatility -
    initialVolatility = [parameters.volatility]
    
    # setup the objective function -
    OF(p) = _iv_objective_function(p, optionPriceValue, parameters; modelTreeType = modelTreeType, optionContractType = optionContractType, earlyExercise = earlyExercise)

    # call the optimizer -
    opt_result = Optim.optimize(OF,initialVolatility,BFGS())

    # return the result -
    return Optim.minimizer(opt_result)[1]
end
# ---------------------------------------------------------------- #