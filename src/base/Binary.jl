# --- PRIVATE METHODS --------------------------------------------------------------------------------------- #
function _compute_crr_index_array(numberOfLevels::Int64)
    
    # ok, so lets build an index array -
    number_items_per_level = [(i+1) for i=0:numberOfLevels]
    tmp_array = Array{Int64,1}()
    theta = 0
    for value in number_items_per_level
        for index = 1:value
            push!(tmp_array,theta)
        end
        theta = theta + 1
    end

    N = sum(number_items_per_level[1:(numberOfLevels-1)])
    index_array = Array{Int64,2}(undef,N,3)
    for row_index = 1:N
    
        #index_array[row_index,1] = tmp_array[row_index]
        index_array[row_index,1] = row_index
        index_array[row_index,2] = row_index + 1 + tmp_array[row_index]
        index_array[row_index,3] = row_index + 2 + tmp_array[row_index]
    end

    return index_array
end

function _compute_full_binomial_index_array(numberOfLevels::Int64)

    number_of_elements = (2^(Int(numberOfLevels))) - 1
    index_array = Array{Int64,2}(undef,number_of_elements,3)
    
    # populate the index array -
    for index = 1:number_of_elements

        # compute the child indexs -
        left_child_index = 2*(index - 1) + 2
        right_child_index = 2*(index - 1) + 3
        
        # grab and go -
        index_array[index,1] = index
        index_array[index,2] = left_child_index
        index_array[index,3] = right_child_index
    end

    # return -
    return index_array
end

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

function _build_binary_lattice_underlying_price_array(basePrice::Float64, volatility::Float64, timeToExercise::Float64;
    numberOfLevels::Int64 = 100)::PSResult

    # compute up and down perturbations -
    Δt = (timeToExercise/numberOfLevels)    
    U = exp(volatility * √Δt)
    D = 1 / U

    # compute the index array =
    index_array = _compute_crr_index_array(numberOfLevels);
    max_element = index_array[end,end]
    N = index_array[end,1]

    # compute price array -
    priceArray = zeros(max_element)
    priceArray[1] = basePrice
    for row_index = 1:N

        # parent index -
        parent_index = index_array[row_index,1]
        left_child_index = index_array[row_index,2]
        right_child_index = index_array[row_index,3]

        # get the basePrice -
        basePrice = priceArray[parent_index]

        # compute the prices -
        down_price = basePrice*D
        priceArray[right_child_index] = down_price
        
        up_price = basePrice*U
        priceArray[left_child_index] = up_price
    end

    # return the price array -
    return PSResult{Array{Float64,1}}(priceArray)
end

function _build_binary_lattice_option_value_array(intrinsicValueArray::Array{Float64,1}, latticeModel::PSBinaryLatticeModel; 
    earlyExcercise::Bool = true, numberOfLevels::Int64 = 100)::PSResult

    # initialize -
    contract_price_array = copy(intrinsicValueArray)
    
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
    index_table = _compute_crr_index_array(numberOfLevels)
    N = index_table[end,1]

    # ok, so now lets compute the value for the nodes -
    for compute_index = 1:N
        
        # get the indexs -
        parent_node_index = index_table[compute_index,1]
        child_left_index = index_table[compute_index,2]
        child_right_index = index_table[compute_index,3]

        # compute -
        contract_price = DF*(p*contract_price_array[child_left_index]+(1-p)*contract_price_array[child_right_index])
        if (earlyExcercise == false)
            contract_price_array[parent_node_index] = contract_price
        else
            excercise_value = contract_price_array[parent_node_index]
            contract_price_array[parent_node_index] = max(excercise_value,contract_price)
        end
    end

    # setup the results tuple -
    results_tuple = (option_index_table=index_table, option_contract_price_array=contract_price_array, U=U, D=D, PUP=p, PDOWN=(1-p), DF=DF)

    # return -
    return PSResult(results_tuple)
end
# ----------------------------------------------------------------------------------------------------------- #


# --- PUBLIC METHODS ---------------------------------------------------------------------------------------- #

function compute_underlying_price_distribution(timeStepIndex::Int64,latticeModel::PSBinaryLatticeModel, baseUnderlyingPrice::Float64, 
    movementFunction::Function)::PooksoftBase.PSResult

    # initialize -
    priceDistributionArray = Array{Float64,2}(undef,(timeStepIndex+1), 4)
    riskFreeRate = latticeModel.riskFreeRate
    kIndexVector = range(0,stop=timeStepIndex,step=1) |> collect

    # compute the up and downmove values -
    (u,d) = movementFunction(latticeModel)

    # compute the probability p of an *up* move -
    p = ((1 + riskFreeRate) - d)/(u - d)

    # main loop -
    for (index,k) in enumerate(kIndexVector)

        # compute the price -
        price = baseUnderlyingPrice*(u^k)*(d^(timeStepIndex - k))

        # compute the probability -
        prob = binomial(timeStepIndex,k)*(p^k)*((1 - p)^(timeStepIndex-k))

        # package -
        priceDistributionArray[index,1] = timeStepIndex
        priceDistributionArray[index,2] = k
        priceDistributionArray[index,3] = prob
        priceDistributionArray[index,4] = price
    end
    
    # return -
    return PSResult{Array{Float64,2}}(priceDistributionArray)
end

"""
    option_contract_price(contractSet::Set{PSAbstractAsset}, latticeModel::PSBinaryLatticeModel, baseUnderlyingPrice::Float64; 
        earlyExercise::Bool = false)::PooksoftBase.PSResult

Estimate the price of a contract using a binary lattice pricing model.
"""
function option_contract_price(contractSet::Set{PSAbstractAsset}, latticeModel::PSBinaryLatticeModel, baseUnderlyingPrice::Float64; 
    earlyExercise::Bool = true)::PooksoftBase.PSResult

    # initialize -
    option_contract_price = 0.0

    # we need to get some stuff from the lattice model -
    volatility = latticeModel.volatility
    timeToExercise = latticeModel.timeToExercise
    numberOfLevels = latticeModel.numberOfLevels

    # compute the price array -
    result = _build_binary_lattice_underlying_price_array(baseUnderlyingPrice, volatility, timeToExercise; 
        numberOfLevels = numberOfLevels)
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
    result = _build_binary_lattice_option_value_array(iv_array, latticeModel; 
        earlyExcercise = earlyExercise, numberOfLevels = numberOfLevels)
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