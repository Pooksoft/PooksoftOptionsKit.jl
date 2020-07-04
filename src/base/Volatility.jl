# -- PRIVATE FUNCTIONS ------------------------------------------- #
function _iv_objective_function(x, parameters::PSOptionKitPricingParameters; modelTreeType::Symbol = :binary, 
    optionContractType::Symbol = :call, earlyExercise::Bool = false)

    # create a new paramter w/new volatility -
    perturbedVolatility = x[1]
    perturbedParameters = PSOptionKitPricingParameters(parameters.baseAssetPrice, perturbedVolatility, parameters.timeToExercise, parameters.numberOfLevels,
        parameters.strikePrice, parameters.riskFreeRate, parameters.dividendRate)

    # re-compute the option price -
    perturbedOptionPriceTree = option_contract_price(perturbedParameters; modelTreeType = modelTreeType, optionContractType = optionContractType)

end
# ---------------------------------------------------------------- #

# -- PUBLIC FUNCTIONS -------------------------------------------- #
function estimate_implied_volatility(parameters::PSOptionKitPricingParameters; modelTreeType::Symbol = :binary, 
    optionContractType::Symbol = :call, earlyExercise::Bool = false)



end
# ---------------------------------------------------------------- #