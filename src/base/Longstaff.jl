# --- PRIVATE METHODS --------------------------------------------------------------------------------------- #
function _fit_local_regression_model(X::Array{Float64,1},Y::Array{Float64,1})::PSResult

    # what is the size of X?
    number_of_paths = length(X)
        
    # initialize -
    M = zeros(number_of_paths,3)

    # compute the M matrix -
    for path_index = 1:number_of_paths
        M[path_index,1] = 1.0
        M[path_index,2] = X[path_index]
        M[path_index,3] = (X[path_index])^2
    end

    # compute the LS parameters -
    a = inv(transpose(M)*M)*transpose(M)*Y

    # Wrap -
    model = LocalExpectationRegressionModel(a[1],a[2],a[3])

    # return -
    return PSResult{LocalExpectationRegressionModel}(model)
end

function _evaluate_local_regression_model(model::LocalExpectationRegressionModel,X::Array{Float64,1})::PSResult

    # initialize -
    f_value_array = Array{Float64,1}()
    
    # get the parameters for the model -
    a0 = model.a0
    a1 = model.a1
    a2 = model.a2

    # compute -
    for value in X
        term_1 = a0
        term_2 = a1*value
        term_3 = a2*(value)^2
        f_value = term_1+term_2+term_3
        push!(f_value_array,f_value)
    end

    # return -
    return PSResult{Array{Float64,1}}(f_value_array)
end

function _calculate_intrinsic_value_trade_legs(contractSet::Set{PSAbstractAsset},underlyingPrice::Float64)::PSResult

    # initialize -
    tmp_array = Float64[]
    
    # main loop -
    for contract in contractSet
        result = intrinsic_value(contract,underlyingPrice)
        if (isa(result.value,Exception) == true)
            return result
        end
        iv_value = result.value.intrinsic_value
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
    option_excercise_reward_table = zeros(number_of_paths,number_of_time_steps-1)

    # initialize an empty profit_loss_table -
    intrinsic_value_table = zeros(number_of_paths,number_of_time_steps)

    # ok, so before we do anything about excerising the option contract, lets complete the P/L table -
    for path_index = 1:number_of_paths
        for time_index = 1:number_of_time_steps

            # grab the potential price -
            underlying_price_value = underlying_price_table[path_index, time_index]

            # process each leg of the trade - 
            result = _calculate_intrinsic_value_trade_legs(contractSet, underlying_price_value)
            if (isa(result.value,Exception) == true)
                return result
            end
            total_intrinsic_value = result.value

            # capture this value -
            intrinsic_value_table[path_index,time_index] = total_intrinsic_value
        end
    end

    # ok depending upon whether this is an American (USA,USA!) or an European option 
    # we do different things = earlyExercise = false is a European option
    if (earlyExercise == false)
        
        # what is the deltaT?
        ΔT = (number_of_time_steps*timeMultiplier)*(1.0/364.5)
        d = exp(-1*riskFreeRate*ΔT)

        # compute the value -
        for path_index = 1:number_of_paths
            value = d*(intrinsic_value_table[path_index,end])
            option_excercise_reward_table[path_index,end] = value
        end        
    else

        # What is my d?
        ΔT = (1.0*timeMultiplier)*(1.0/364.5)
        d = exp(-1*riskFreeRate*ΔT)

        # initialize the last col of the cost table -
        for path_index = 1:number_of_paths
            value = 1.0*(intrinsic_value_table[path_index,end])
            option_excercise_reward_table[path_index,end] = value
        end   

        # so the option cost table
        backward_index_collection = collect(range(number_of_time_steps,step=-1,stop=2))
        for time_index in backward_index_collection

            # get all the Y's for the regression -
            Y = intrinsic_value_table[:,time_index]

            # get all of the X's (we'll filter out OTM rows later) -
            X = underlying_price_table[:,time_index-1]
            
            # which of the X's are ITM?
            itm_index_array = findall(x->x>0, intrinsic_value_table[:,time_index-1])
            Xdata = X[itm_index_array]
            Ydata = Y[itm_index_array].*d 

            # compute the local model -
            result = _fit_local_regression_model(Xdata,Ydata)
            if (isa(result.value,Exception) == true)
                return result
            end
            local_model = result.value

            # which paths will have early an early excercise event?
            # lets compare what we would get if we excercised now, versus waiting -
            result = _evaluate_local_regression_model(local_model,Xdata)
            if (isa(result.value,Exception) == true)
                return result
            end
            Ycontinuation = result.value

            # ok, so let's compare the excercise value versus the Ycontinuation -
            for (index,itm_index) in enumerate(itm_index_array)
                
                excercise_value = intrinsic_value_table[itm_index,time_index-1]
                continuation_value = Ycontinuation[index]
            
                if (excercise_value>continuation_value)
                    option_excercise_reward_table[itm_index,time_index-1] = excercise_value
                    option_excercise_reward_table[itm_index,time_index] = 0.0
                    
                    # we excercised - so all future times are equal to zero
                    for local_time_index = time_index:number_of_time_steps
                        # option_excercise_reward_table[itm_index,local_time_index] = 0.0
                    end
                else
                    option_excercise_reward_table[itm_index,time_index-1] = 0.0
                end
            end
        end
    end

    # return - what is going on?
    return PSResult{Array{Float64,2}}(option_excercise_reward_table)
end
# ----------------------------------------------------------------------------------------------------------- #

# --- PUBLIC METHODS ---------------------------------------------------------------------------------------- #
# function longstaff_option_contract_price(contractSet::Set{PSAbstractAsset}, model::PSGeometricBrownianMotionModelParameters, initialCondition::Float64, tspan::Tuple{Float64,Float64}, timeStep::Float64; 
#     number_of_trials::Int64=10000, return_time_step::Float64 = 1.0, earlyExercise::Bool = false, riskFreeRate::Float64 = 0.015, timeMultiplier=1.0)::PSResult

#     # TODO: checks - all ok with args?

#     # simulate the underlying asset price dynamics -
#     result = evaluate(model,initialCondition,tspan,timeStep;number_of_trials=number_of_trials,return_time_step=return_time_step)
#     if (isa(result.value,Exception) == true)
#         return result
#     end

#     # we have data: this call returns a named tuple w/T,X,μ,σ
#     X = result.value.X

#     # setup the price table -
#     underlying_price_table = transpose(X)

#     # call the valuation method -
#     return longstaff_option_contract_price(contractSet, underlying_price_table; 
#         earlyExercise=earlyExercise, riskFreeRate=riskFreeRate, timeMultiplier=timeMultiplier)
# end

"""
    longstaff_option_contract_price
"""
function longstaff_option_contract_price(contractSet::Set{PSAbstractAsset}, underlyingPriceTable::Array{Float64,2}; 
    earlyExercise::Bool = false, riskFreeRate::Float64 = 0.015, timeMultiplier=1.0)::PSResult

    # update the option cost table -
    result = _calculate_options_cost_table(contractSet, underlyingPriceTable; earlyExercise = earlyExercise)
    if (isa(result.value,Exception) == true)
        return result
    end
    option_price_table = result.value

    # return -
    return PSResult{Array{Float64,2}}(option_price_table)
end
# ----------------------------------------------------------------------------------------------------------- #