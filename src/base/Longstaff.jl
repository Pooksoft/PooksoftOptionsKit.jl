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
    price_table = transpose(X)

    # return -
    return PSResult{Array{Float64,2}}(price_table)
end