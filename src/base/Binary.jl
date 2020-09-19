# --- PRIVATE METHODS --------------------------------------------------------------------------------------- #
# array based -
function _build_binary_lattice_intrinsic_value_array(contractSet::Set{PSAbstractAsset}, binaryPriceArray::Array{Float64,1})::PSResult

    # initialize -
    intrinsic_value_array = similar(binaryPriceArray)

    # ok, so lets go through each price, compute the intrinsic value - and then store 
    for (index,price) in enumerate(binaryPriceArray)
        
        # ok, get the underlying price -
        underlying_price_value = binaryPriceArray[index]

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

function _build_binary_lattice_underlying_price_array(basePrice::Float64, volatility::Float64, timeToExercise::Int; numberOfLevels::Int64 = 14)::PSResult

    # compute up and down perturbations -
    Δt = (timeToExercise/numberOfLevels)    
    U = exp(volatility * √Δt)
    D = 1 / U

    # compute price array -
    number_of_elements = (2^(Int(numberOfLevels))) - 1
    priceArray = zeros(number_of_elements)
    priceArray[1] = basePrice

    # populate the prive array -
    for index = 1:number_of_elements

        # get the basePrice -
        basePrice = priceArray[index]

        # compute the prices -
        down_price = basePrice*D
        up_price = basePrice*U
    
        # add the prices to the array -
        left_index = 2*(index - 1) + 2
        right_index = 2*(index - 1) + 3

        # note - we need to check that we don't write into the array past the end
        if (left_index<=number_of_elements)
            priceArray[left_index] = up_price
        end

        if (right_index<=number_of_elements)
            priceArray[right_index] = down_price
        end
    end

    # return the price array -
    return PSResult{Array{Float64,1}}(priceArray)
end

function _build_binary_lattice_option_value_array(intrinsicValueArray::Array{Float64,1}, latticeModel::PSBinaryLatticeModel; earlyExcercise::Bool = false, numberOfLevels::Int64 = 14)::PSResult

    # get stuff from the lattice model -
    volatility = latticeModel.volatility
    timeToExercise = latticeModel.timeToExercise
    riskFreeRate = latticeModel.riskFreeRate
    dividendRate = latticeModel.dividendRate

    # compute up and down perturbations -
    Δt = (timeToExercise/numberOfLevels)   
    U = exp(volatility * √Δt)
    D = 1 / U
    p = (exp((riskFreeRate - dividendRate)*Δt) - D)/(U - D)
    DF = exp(-riskFreeRate*Δt)

    # create a index table -
    number_of_elements = (2^(Int(numberOfLevels)-1)) - 1
    index_table = zeros(number_of_elements,4)
    backwards_index_array = range(number_of_elements,step=-1,stop=1) |> collect
    for (forward_index, backward_index) in enumerate(backwards_index_array)
        
        # add the prices to the array -
        left_index = 2*(backward_index - 1) + 2
        right_index = 2*(backward_index - 1) + 3
    
        # populate the index table -
        index_table[forward_index,1] = backward_index
        index_table[forward_index,2] = left_index
        index_table[forward_index,3] = right_index
    end

    # ok, so now lets compute the value for the nodes -
    for compute_index = 1:number_of_elements
        
        # get the indexs -
        parent_node_index = Int(index_table[compute_index,1])
        child_left_index = Int(index_table[compute_index,2])
        child_right_index = Int(index_table[compute_index,3])

        # compute the value -
        contract_value = DF*(p*intrinsicValueArray[child_left_index]+(1-p)*intrinsicValueArray[child_right_index])
        if (earlyExcercise == false)
            index_table[compute_index,4] = contract_value
        else
            iv_value = intrinsicValueArray[parent_node_index]
            index_table[compute_index,4] = max(iv_value,contract_value)
        end
    end

    # calculate the price -
    C = DF*(p*index_table[end-1,end]+(1-p)*index_table[end-2,end])

    # setup the results tuple -
    results_tuple = (option_value_table=index_table, option_contract_price=C, U=U, D=D, PUP=p, PDOWN=(1-p), DF=DF)

    # return -
    return PSResult(results_tuple)
end
# ----------------------------------------------------------------------------------------------------------- #


# --- PUBLIC METHODS ---------------------------------------------------------------------------------------- #
function option_contract_price(contractSet::Set{PSAbstractAsset}, latticeModel::PSBinaryLatticeModel, baseUnderlyingPrice::Float64; 
    earlyExercise::Bool = false, numberOfLevels::Int64 = 14)::PSResult

    # initialize -
    option_contract_price = 0.0

    # we need to get some stuff from the lattice model -
    volatility = latticeModel.volatility
    timeToExercise = latticeModel.timeToExercise

    # compute the price array -
    result = _build_binary_lattice_underlying_price_array(baseUnderlyingPrice, volatility, timeToExercise; numberOfLevels=numberOfLevels)
    if (isa(result.value,Exception) == true)
        return result
    end
    lattice_price_array = result.value

    # compute the intrinsic value array -
    result = _build_binary_lattice_intrinsic_value_array(contractSet,lattice_price_array)
    if (isa(result.value,Exception) == true)
        return result
    end
    iv_array = result.value

    # ok, let's build the option value array -
    result = _build_binary_lattice_option_value_array(iv_array, latticeModel; earlyExcercise = earlyExercise, numberOfLevels=numberOfLevels)
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