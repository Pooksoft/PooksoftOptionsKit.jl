# --- PRIVATE METHODS --------------------------------------------------------------------------------------- #
function _fit_local_regression_model(X::Array{Float64,1},Y::Array{Float64,1})::PSResult
end

function _evaluate_local_regression_model(model::LocalExpectationRegressionModel,X::Array{Float64,1})::PSResult
end

function _calculate_intrinsic_value_trade_legs(contractSet::Set{PSAbstractAsset},underlyingPrice::Float64)::PSResult

    # initialize -
    tmp_array = Float64[]
    
    # main loop -
    for contract in contractSet
        iv_value = intrinsic_value(contract,underlyingPrice)
        push!(tmp_array,iv_value)
    end

    # total intrinsic value -
    total_intrinsic_value = sum(tmp_array)

    # return -
    return PSResult{Float64}(total_intrinsic_value)
end

function _calculate_options_cost_table(contractSet::Set{PSAbstractAsset}, underlying_price_table::Array{Float64,2}; 
    riskFreeRate::Float64 = 0.015, timeMultiplier=1.0, earlyExercise::Bool = false)::PSResult

    # now that we have the underlying price table, let's operate on this table to estimate values -
    # what is the size of the underlying price table?
    (number_of_paths,number_of_time_steps) = size(underlying_price_table)

    # initialize an empty option_cost_table -
    option_cost_table = zeros(number_of_paths,number_of_time_steps)

    # ok depending upon whether this is an American (USA,USA!) or an European option 
    # we do different things = earlyExercise = false is a European option
    if (earlyExercise == false)
        
        # only the last col will *potentially* have non-zero values
        for path_index = 1:number_of_paths
            
            # grab the potential price -
            underlying_price_value = underlying_price_table[path_index,end]

            # process each leg of the trade - 
            result = _calculate_intrinsic_value_trade_legs(contractSet, underlying_price_value)
            if (isa(result.value,Exception) == true)
                return result
            end
            total_intrinsic_value = result.value

            # capture this value -
            option_cost_table[path_index,end] = total_intrinsic_value
        end

        # With a European option, I'm done here - 
        # we'll pop out of the loop, and return the option cost table
    else

        # fill in the last col (European case)
        for path_index = 1:number_of_paths
            
            # grab the potential price -
            underlying_price_value = underlying_price_table[path_index,end]

            # process each leg of the trade - 
            result = _calculate_intrinsic_value_trade_legs(contractSet, underlying_price_value)
            if (isa(result.value,Exception) == true)
                return result
            end
            total_intrinsic_value = result.value

            # capture this value -
            option_cost_table[path_index,end] = total_intrinsic_value
        end

        # ok, so if we get here, then I have the "hard" case, an American (USA,USA!) contract
        # we are already filled in the last col -
        backward_index_collection = collect(range(number_of_time_steps,step=-1,stop=2))
        for time_index in backward_index_collection
            
            # compute the Y for the regression -
            Y = option_cost_table[:,time_index]

            # compute the intrinsic value at time-index - 1 
            for path_index = 1:number_of_paths
            
                # grab the potential price -
                underlying_price_value = underlying_price_table[path_index,time_index-1]
    
                # process each leg of the trade - 
                result = _calculate_intrinsic_value_trade_legs(contractSet, underlying_price_value)
                if (isa(result.value,Exception) == true)
                    return result
                end
                total_intrinsic_value = result.value
    
                # capture this value -
                option_cost_table[path_index,time_index-1] = total_intrinsic_value
            end

            # get all of the X's (we'll filter out OTM rows later) -
            X = underlying_price_table[:,time_index-1]
            
            # which of the X's are ITM?
            itm_index = findall(x->x>0, option_cost_table[path_index,time_index-1])
            Xdata = X[itm_index]
            Ydata = Y[itm_index].*exp(-riskFreeRate*timeMultiplier)    # discounted back to today

            # compute the local model -
            result = _fit_local_regression_model(Xdata,Ydata)
            if (isa(result.value,Exception) == true)
                return result
            end
            local_model = result.value

            # which paths will have early an early excercise event?
            # lets compare what we would get if we excercised now, versus waiting -
            

        end

    end

    # return -
    return PSResult{Array{Float64,2}}(option_cost_table)
end
# ----------------------------------------------------------------------------------------------------------- #

# --- PUBLIC METHODS ---------------------------------------------------------------------------------------- #
function longstaff_option_contract_price(contractSet::Set{PSAbstractAsset}, model::PSGeometricBrownianMotionModelParameters, initialCondition::Float64, tspan::Tuple{Float64,Float64}, timeStep::Float64; 
    number_of_trials::Int64=10000, return_time_step::Float64 = 1.0, earlyExercise::Bool = false, riskFreeRate::Float64 = 0.015, timeMultiplier=1.0)::PSResult

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
    result = _calculate_options_cost_table(contractSet, underlying_price_table; earlyExercise = earlyExercise)
    if (isa(result.value,Exception) == true)
        return result
    end
    option_price_table = result.value

    # return -
    return PSResult{Array{Float64,2}}(option_price_table)
end
# ----------------------------------------------------------------------------------------------------------- #