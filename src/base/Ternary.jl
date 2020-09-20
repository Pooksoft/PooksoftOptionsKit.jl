# --- PRIVATE METHODS --------------------------------------------------------------------------------------- #

# array based -
function _build_ternary_lattice_intrinsic_value_array(contractSet::Set{PSAbstractAsset}, ternaryPriceArray::Array{Float64,1})::PSResult

    # initialize -
    intrinsic_value_array = similar(ternaryPriceArray)

    # ok, so lets go through each price, compute the intrinsic value - and then store 
    for (index,price) in enumerate(ternaryPriceArray)
        
        # ok, get the underlying price -
        underlying_price_value = ternaryPriceArray[index]

        # compute the intrinsic value -
        result = intrinsic_value(contractSet,underlying_price_value)
        if (isa(result.value,Exception) == true)
            return result
        end
        iv_value = result.value

        # add the iv to the array - index should work out
        intrinsic_value_array[index] = iv_value
    end

    # return -
    return PSResult{Array{Float64,1}}(intrinsic_value_array)
end

function _build_ternary_lattice_underlying_price_array(basePrice::Float64, volatility::Float64, timeToExercise::Int)::PSResult

    # compute up and down perturbations -
    numberOfLevels = timeToExercise + 1     # assumption: our time unit is 1 day *always* = is this legit?
    Δt = (1.0)    
    U = exp(volatility * sqrt(2*Δt))
    D = 1.0 / U
    C = 1.0

    # compute price array -
    number_of_elements = Int64(((3^numberOfLevels) - 1)/2)
    priceArray = zeros(number_of_elements)
    priceArray[1] = basePrice
    
    # populate the ternary price tree -
    for index = 1:number_of_elements

        # get the basePrice -
        basePrice = priceArray[index]

        # compute the prices -
        down_price = basePrice*D
        up_price = basePrice*U
        center_price = basePrice*C

        # add the prices to the array -
        left_index = 3*(index - 1) + 2
        center_index = 3*(index - 1) + 3
        right_index = 3*(index - 1) + 4

        # note - we need to check that we don't write into the array past the end
        if (left_index<=number_of_elements)
            priceArray[left_index] = up_price
        end

        if (center_index<=number_of_elements)
            priceArray[center_index] = center_price
        end

        if (right_index<=number_of_elements)
            priceArray[right_index] = down_price
        end
    end

    # return the price array -
    return PSResult{Array{Float64,1}}(priceArray)
end

function _build_ternary_lattice_option_value_array(intrinsicValueArray::Array{Float64,1}, latticeModel::PSTernaryLatticeModel; earlyExcercise::Bool = false)::PSResult

    # initialize -
    contract_price_array = copy(intrinsicValueArray)
    
    # get stuff from the lattice model -
    σ = latticeModel.volatility
    timeToExercise = latticeModel.timeToExercise
    riskFreeRate = latticeModel.riskFreeRate
    dividendRate = latticeModel.dividendRate

    # compute the probability -
    numberOfLevels = timeToExercise + 1     # assumption: our time unit is 1 day *always* = is this legit?
    Δt = (1.0)   
    T1 = exp((riskFreeRate - dividendRate)*(Δt/2))
    T2 = exp(-σ*sqrt(Δt/2))
    T3 = exp(σ*sqrt(Δt/2))
    pup = ((T1 - T2)/(T3 - T2))^2
    pdown = ((T3 - T1)/(T3 - T2))^2
    DF = exp(-riskFreeRate*Δt)
    U = exp(σ*sqrt(2*Δt))
    D = 1.0 / U
    C = 1.0

    # create a index table -
    # number_of_elements = Int64(((3^numberOfLevels) - 1)/2)
    number_of_elements = numberOfLevels
    index_table = zeros(numberOfLevels, 5)
    backwards_index_array = range(numberOfLevels, step=-1,stop=1) |> collect
    for (forward_index, backward_index) in enumerate(backwards_index_array)
        
        # add the prices to the array -
        left_index = 3*(backward_index - 1) + 2
        center_index = 3*(backward_index - 1) + 3
        right_index = 3*(backward_index - 1) + 4
    
        # populate the index table -
        index_table[forward_index,1] = backward_index
        index_table[forward_index,2] = left_index
        index_table[forward_index,3] = center_index
        index_table[forward_index,4] = right_index
    end

    # @show index_table

    # ok, so now lets compute the value for the nodes -
    for compute_index = 1:number_of_elements
        
        # get the indexs -
        parent_node_index = Int(index_table[compute_index,1])
        child_left_index = Int(index_table[compute_index,2])
        child_center_index = Int(index_table[compute_index,3])
        child_right_index = Int(index_table[compute_index,4])

        #@show (parent_node_index,child_left_index,child_center_index,child_right_index)

        # compute -
        contract_price = DF*(pup*contract_price_array[child_left_index]+(pdown)*contract_price_array[child_right_index]+(1-pup-pdown)*contract_price_array[child_center_index])
        if (earlyExcercise == false)
            contract_price_array[parent_node_index] = contract_price
        else
            excercise_value = contract_price_array[parent_node_index]
            contract_price_array[parent_node_index] = max(excercise_value,contract_price)
        end
    end

   # setup the results tuple -
   results_tuple = (option_index_table=index_table, option_contract_price_array=contract_price_array, U=U, D=D, PUP=pup, PDOWN=pdown, PCENTER=(1-pup-pdown), DF=DF)

   # return -
   return PSResult(results_tuple)
end
# ----------------------------------------------------------------------------------------------------------- #

# --- PUBLIC METHODS ---------------------------------------------------------------------------------------- #
function option_contract_price(contractSet::Set{PSAbstractAsset}, latticeModel::PSTernaryLatticeModel, baseUnderlyingPrice::Float64; 
    earlyExercise::Bool = false)::PSResult

    # initialize -
    option_contract_price = 0.0

    # we need to get some stuff from the lattice model -
    volatility = latticeModel.volatility
    timeToExercise = latticeModel.timeToExercise

    # compute the price array -
    result = _build_ternary_lattice_underlying_price_array(baseUnderlyingPrice, volatility, timeToExercise)
    if (isa(result.value,Exception) == true)
        return result
    end
    lattice_price_array = result.value

    # compute the intrinsic value array -
    result = _build_ternary_lattice_intrinsic_value_array(contractSet, lattice_price_array)
    if (isa(result.value,Exception) == true)
        return result
    end
    iv_array = result.value

    # ok, let's build the option value array -
    result = _build_ternary_lattice_option_value_array(iv_array, latticeModel; earlyExcercise = earlyExercise)
    if (isa(result.value,Exception) == true)
        return result
    end
    cost_calc_tuple = result.value
    
    # create a named tuple and return the results -
    results_tuple = (lattice_price_array=lattice_price_array, intrinsic_value_array = iv_array, cost_calculation_result=cost_calc_tuple)

    # return -
    return PSResult(results_tuple)
end
# ----------------------------------------------------------------------------------------------------------- #