# --- PRIVATE METHODS --------------------------------------------------------------------------------------- #
function _obj_function_breakeven(x,contractSet::Set{PSAbstractAsset})

    # what is the test price?
    underlyingPrice = x[1]

    # what is the PL value at this price?
    result = profit_loss_value(contractSet,underlyingPrice)
    if (isa(result.value,Exception) == true)
        return result
    end
    pl_value = result.value

    # compute the objective function -
    obj_value = (pl_value^2)+10000000*max(0.0,-1*underlyingPrice)

    # return -
    return obj_value
end
# ----------------------------------------------------------------------------------------------------------- #

# --- PUBLIC METHODS ---------------------------------------------------------------------------------------- #
function compute_breakeven_price(contractSet::Set{PSAbstractAsset}; initialPrice::Float64=1.0)::PSResult

    # setup initial price -
    xinitial = [initialPrice]

    # setup the objective function -
    OF(p) = _obj_function_breakeven(p, contractSet)
    
    # call the optimizer -
    opt_result = optimize(OF,xinitial,BFGS())
    
    # breakeven price -
    breakeven_price = Optim.minimizer(opt_result)[1]

    # return -
    return PSResult(breakeven_price)
end
# ----------------------------------------------------------------------------------------------------------- #