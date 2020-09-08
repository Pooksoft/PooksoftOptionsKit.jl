# --- PRIVATE METHODS --------------------------------------------------------------------------------------- #
function _calculate_options_cost_table(contractSet::Set{PSAbstractAsset}, underlying_price_table::Array{Float64,2})

    # now that we have the underlying price table, let's operate on this table to estimate values -
    # what is the size of the underlying price table?
    (number_of_paths,number_of_time_steps) = size(underlying_price_table)

    # initialize an empty option_cost_table -
    option_cost_table = zeros(number_of_paths,number_of_time_steps)

    # magic stuff happens here ...
    # ...

    # return -
    return PSResult{Array{Float64,2}}(option_cost_table)
end
# ----------------------------------------------------------------------------------------------------------- #

# --- PUBLIC METHODS ---------------------------------------------------------------------------------------- #
function longstaff_option_contract_price(contractSet::Set{PSAbstractAsset}, model::PSGeometricBrownianMotionModelParameters, initialCondition::Float64, tspan::Tuple{Float64,Float64}, timeStep::Float64; 
    number_of_trials::Int64=10000, return_time_step::Float64 = 1.0)::PSResult

    # TODO: checks - all ok with args?

    # simulate the underlying asset price dynamics -
    result = evaluate(model,initialCondition,tspan,timeStep;number_of_trials=number_of_trials,return_time_step=return_time_step)
    if (isa(result.value,Exception) == true)
        return result
    end

    # we have data: this call returns a named tuple w/T,X,μ,σ
    X = result.value.X

    # setup the price table -
    underlying_price_table = transpose(X)

    # update the option cost table -
    result = _calculate_options_cost_table(contractSet, underlying_price_table)
    if (isa(result.value,Exception) == true)
        return result
    end
    option_price_table = result.value

    # return -
    return PSResult{Array{Float64,2}}(option_price_table)
end
# ----------------------------------------------------------------------------------------------------------- #