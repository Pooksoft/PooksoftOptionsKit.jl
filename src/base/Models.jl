function crr_am_put(S, K, r, σ, t, N)
    Δt = t / N
    U = exp(σ * √Δt)
    D = 1 / U
    R = exp(r * Δt)
    p = (R - D) / (U - D)
    q = (U - R) / (U - D)
    Z = [max(0, K - S * exp((2 * i - N) * σ * √Δt)) for i = 0:N]
    
    for n = N-1:-1:0
        for i = 0:n
            x = K - S * exp((2 * i - n) * σ * √Δt)
            y = (q * Z[i+1] + p * Z[i+2]) / R
            Z[i+1] = max(x, y)
        end
    end

    return Z[1]
end

function update_ternary_price_array!(priceArray::Array{Float64,1}, up::Float64, center::Float64, down::Float64)

    # what is the size of the array?
    number_of_prices = length(priceArray)

    # main loop -
    for index = 1:number_of_prices

        # get the basePrice -
        basePrice = priceArray[index]

        # compute the prices -
        down_price = basePrice*down
        up_price = basePrice*up
        center_price = basePrice*center

        # add the prices to the array -
        left_index = 3*(index - 1) + 2
        center_index = 3*(index - 1) + 3
        right_index = 3*(index - 1) + 4

        # note - we need to check that we don't write into the array past the end
        if (left_index<=number_of_prices)
            priceArray[left_index] = down_price
        end

        if (center_index<=number_of_prices)
            priceArray[center_index] = center_price
        end

        if (right_index<=number_of_prices)
            priceArray[right_index] = up_price
        end
    end

end

function update_binary_price_array!(priceArray::Array{Float64,1}, up::Float64, down::Float64)

    # what is the size of the array?
    number_of_prices = length(priceArray)

    # main loop -
    for index = 1:number_of_prices

        # get the basePrice -
        basePrice = priceArray[index]

        # compute the prices -
        down_price = basePrice*down
        up_price = basePrice*up
    
        # add the prices to the array -
        left_index = 2*(index -1) + 2
        right_index = 2*(index - 1) + 3

        # note - we need to check that we don't write into the array past the end
        if (left_index<=number_of_prices)
            priceArray[left_index] = down_price
        end

        if (right_index<=number_of_prices)
            priceArray[right_index] = up_price
        end
    end
end

function build_binary_tree_node(priceArray::Array{Float64,1}, root::Union{Nothing, PSBinaryPriceTreeNode}, nodeIndex::Int64, maxCount::Int64)

    if (nodeIndex <= maxCount)
        
        # setup -
        tmpNode = PSBinaryPriceTreeNode()
        tmpNode.price = priceArray[nodeIndex]
        
        # Put dummy values on the L and R nodes -
        tmpNode.left = nothing
        tmpNode.right = nothing
        tmpNode.intrinsicValue = nothing

        # setup the root -
        root = tmpNode

        # insert L (down price)
        root.left = build_binary_tree_node(priceArray, root.left, 2*(nodeIndex - 1) + 2, maxCount)

        # insert R (up price)
        root.right = build_binary_tree_node(priceArray, root.right, 2*(nodeIndex - 1) + 3, maxCount)
    end

    # return -
    return root
end

function build_ternary_tree_node(priceArray::Array{Float64,1}, root::Union{Nothing, PSTernaryPriceTreeNode}, nodeIndex::Int64, maxCount::Int64)

    if (nodeIndex <= maxCount)
        
        # setup -
        tmpNode = PSTernaryPriceTreeNode()
        tmpNode.price = priceArray[nodeIndex]
        
        # Put dummy values on the L and R nodes -
        tmpNode.left = nothing
        tmpNode.center = nothing
        tmpNode.right = nothing
        tmpNode.intrinsicValue = nothing

        # setup the root -
        root = tmpNode

        # insert L (down price)
        root.left = build_ternary_tree_node(priceArray, root.left, 3*(nodeIndex - 1) + 2, maxCount)

        # insert C (no change)
        root.center = build_ternary_tree_node(priceArray, root.center, 3*(nodeIndex - 1) + 3, maxCount)

        # insert R (up price)
        root.right = build_ternary_tree_node(priceArray, root.right, 3*(nodeIndex - 1) + 4, maxCount)
    end

    # return -
    return root
end

# Binary =====================================================================================
function calculate_call_node_value(node::PSBinaryPriceTreeNode,strikePrice::Float64)

    # get the price -
    price = node.price
    
    # calculate the intrinsicValue -
    node.intrinsicValue = max((price - strikePrice),0)
    node.americanOptionValue = max((price - strikePrice),0)      # we'll update this later -
    node.europeanOptionValue = max((price - strikePrice),0)      # we'll update this later -

    # work on my kids -
    if (node.left !== nothing && node.right !== nothing)
        calculate_call_node_value(node.left,strikePrice)
        calculate_call_node_value(node.right,strikePrice)    
    end
end

function calculate_put_node_value(node::PSBinaryPriceTreeNode,strikePrice::Float64)

    # get the price -
    price = node.price
    
    # calculate the intrinsicValue -
    node.intrinsicValue = max((strikePrice - price),0)

    # work on my kids -
    if (node.left !== nothing && node.right !== nothing)
        calculate_put_node_value(node.left,strikePrice)
        calculate_put_node_value(node.right,strikePrice)    
    end
end

function compute(node::PSBinaryPriceTreeNode, probability::Float64, discountFactor::Float64, 
    currentDepth::Int64, targetDepth::Int64)

    # ok - are we at the target depth?
    if (currentDepth == targetDepth)

        # european -
        # ok, we are at the depth we need, grab my kids and put them in the target set -
        L = node.left.europeanOptionValue       # down
        R = node.right.europeanOptionValue      # up
        totalValue = discountFactor*(probability*R+(1.0 - probability)*L)
        node.europeanOptionValue = totalValue

        # american -
        L = node.left.americanOptionValue           # down
        R = node.right.americanOptionValue          # up
        totalValue = discountFactor*(probability*R+(1.0 - probability)*L)
        
        # compute the american value -
        node.americanOptionValue = max(totalValue, node.intrinsicValue)
    else
        
        # ok, so we are *not* at the target depth -
        compute(node.left, probability, discountFactor, (currentDepth + 1), targetDepth)
        compute(node.right, probability, discountFactor, (currentDepth + 1), targetDepth)
    end
end

function _build_binary_price_tree(basePrice::Float64, volatility::Float64, timeToExercise::Float64, 
    numberOfLevels::Int)::PSBinaryPriceTree

    # checks -
    # ....

    # compute up and down perturbations -
    Δt = timeToExercise/numberOfLevels
    U = exp(volatility * √Δt)
    D = 1 / U

    # compute price array -
    number_of_elements = (2^numberOfLevels) - 1
    priceArray = zeros(number_of_elements)
    priceArray[1] = basePrice
    update_binary_price_array!(priceArray,U,D)

    # build the root node -
    root = PSBinaryPriceTreeNode()
    root.intrinsicValue = nothing

    # assemble tree root -
    root = build_binary_tree_node(priceArray,root,1,number_of_elements)

    # build tree -
    tree = PSBinaryPriceTree(root, Δt, U, D, numberOfLevels)

    # return -
    return tree
end

function _build_call_option_intrinsic_value_tree(tree::PSBinaryPriceTree, strikePrice::Float64)::PSBinaryPriceTree
    
    # update the root - walk through the tree, and calc the intrinsic values -
    calculate_call_node_value(tree.root, strikePrice)

    # return the updated tree -
    return tree
end

function _build_put_option_intrinsic_value_tree(tree::PSBinaryPriceTree, strikePrice::Float64)::PSBinaryPriceTree
    
    # update the root - walk through the tree, and calc the intrinsic values -
    calculate_put_node_value(tree.root, strikePrice)

    # return the updated tree -
    return tree
end

function _build_multileg_option_intrinsic_value_tree(tree::PSBinaryPriceTree, optionLegSet::Set{PSAbstractAsset})::PSBinaryPriceTree 

    

end

function _option_contract_price(tree::PSBinaryPriceTree, riskFreeRate::Float64, dividendRate::Float64)

    # risk free rate and dividendRate are percentages, so we need to convert:
    riskFreeRate = (1/100)*riskFreeRate
    dividendRate = (1/100)*dividendRate

    # compute U, D, DT and p -
    Δt = tree.Δt
    U = tree.U
    D = tree.D
    p = (exp((riskFreeRate - dividendRate)*Δt) - D)/(U - D)
    DF = exp(-riskFreeRate*Δt)
    maxDepth = tree.depth

    # process the tree -
    depth_index_array = collect(range((maxDepth - 1),step=-1,stop=1))
    for depth_index in depth_index_array
        
        # update the tree -
        compute(tree.root, p, DF, 1, depth_index)        
    end

    # return -
    return tree
end
# ============================================================================================

# Ternary ====================================================================================
function calculate_call_node_value(node::PSTernaryPriceTreeNode, strikePrice::Float64)

    # get the price -
    price = node.price
    
    # calculate the intrinsicValue -
    node.intrinsicValue = max((price - strikePrice),0)
    node.americanOptionValue = max((price - strikePrice),0)      # we'll update this later -
    node.europeanOptionValue = max((price - strikePrice),0)      # we'll update this later -

    # work on my kids -
    if (node.left !== nothing && node.right !== nothing)
        calculate_call_node_value(node.left, strikePrice)
        calculate_call_node_value(node.center, strikePrice) 
        calculate_call_node_value(node.right, strikePrice)    
    end
end

function calculate_put_node_value(node::PSTernaryPriceTreeNode, strikePrice::Float64)

    # get the price -
    price = node.price
    
    # calculate the intrinsicValue -
    node.intrinsicValue = max((strikePrice - price),0)

    # work on my kids -
    if (node.left !== nothing && node.right !== nothing)
        calculate_put_node_value(node.left, strikePrice)
        calculate_put_node_value(node.center, strikePrice)  
        calculate_put_node_value(node.right, strikePrice)    
    end
end

function compute(node::PSTernaryPriceTreeNode, probabilityUp::Float64, probabilityDown::Float64, discountFactor::Float64, 
    currentDepth::Int64, targetDepth::Int64)

    # ok - are we at the target depth?
    if (currentDepth == targetDepth)

        # ok, we are at the depth we need, grab my kids and put them in the target set -
        # european -
        L = node.left.europeanOptionValue        # down
        R = node.right.europeanOptionValue       # up
        C = node.center.europeanOptionValue      # center
        totalValue = discountFactor*(probabilityUp*R+probabilityDown*L+(1-(probabilityUp+probabilityDown))*C)
        node.europeanOptionValue = totalValue

        # compute the american value -
        L = node.left.americanOptionValue        # down
        R = node.right.americanOptionValue       # up
        C = node.center.americanOptionValue      # center
        totalValue = discountFactor*(probabilityUp*R+probabilityDown*L+(1-(probabilityUp+probabilityDown))*C)
        node.americanOptionValue = max(totalValue, node.intrinsicValue)

    else
        
        # ok, so we are *not* at the target depth -
        compute(node.left, probabilityUp, probabilityDown, discountFactor, (currentDepth + 1), targetDepth)
        compute(node.center, probabilityUp, probabilityDown, discountFactor, (currentDepth + 1), targetDepth)
        compute(node.right, probabilityUp, probabilityDown, discountFactor, (currentDepth + 1), targetDepth)
    end
end

function _build_ternary_price_tree(basePrice::Float64, volatility::Float64, timeToExercise::Float64, 
    numberOfLevels::Int64)::PSTernaryPriceTree

    # checks -
    # ...

    # compute up and down perturbations -
    Δt = timeToExercise/numberOfLevels
    U = exp(volatility * sqrt(2*Δt))
    D = 1.0 / U
    C = 1.0

    # compute price array -
    number_of_elements = Int64(((3^numberOfLevels) - 1)/2)
    priceArray = zeros(number_of_elements)
    priceArray[1] = basePrice
    update_ternary_price_array!(priceArray,U,C,D)

    # build the root node -
    root = PSTernaryPriceTreeNode()
    root.intrinsicValue = nothing

    # assemble tree root -
    root = build_ternary_tree_node(priceArray,root,1,number_of_elements)

    # build tree -
    tree = PSTernaryPriceTree(root, Δt, U, C, D, volatility, numberOfLevels)

    # return -
    return tree
end

function _build_multileg_option_intrinsic_value_tree(tree::PSTernaryPriceTree, strikePrice::Float64)::PSTernaryPriceTree
end

function _build_call_option_intrinsic_value_tree(tree::PSTernaryPriceTree, strikePrice::Float64)::PSTernaryPriceTree
    
    # update the root - walk through the tree, and calc the intrinsic values -
    calculate_call_node_value(tree.root, strikePrice)

    # return the updated tree -
    return tree
end

function _build_put_option_intrinsic_value_tree(tree::PSTernaryPriceTree, strikePrice::Float64)::PSTernaryPriceTree
    
    # update the root - walk through the tree, and calc the intrinsic values -
    calculate_put_node_value(tree.root, strikePrice)

    # return the updated tree -
    return tree
end

function _option_contract_price(tree::PSTernaryPriceTree, riskFreeRate::Float64, dividendRate::Float64)

    # risk free rate and dividendRate are percentages, so we need to convert:
    riskFreeRate = (1/100)*riskFreeRate
    dividendRate = (1/100)*dividendRate

    # compute U, D, DT and p -
    Δt = tree.Δt
    U = tree.U
    D = tree.D
    C = tree.C
    σ = tree.V

    # compute the probability -
    T1 = exp((riskFreeRate - dividendRate)*(Δt/2))
    T2 = exp(-σ*sqrt(Δt/2))
    T3 = exp(σ*sqrt(Δt/2))

    pup = ((T1 - T2)/(T3 - T2))^2
    pdown = ((T3 - T1)/(T3 - T2))^2
    DF = exp(-riskFreeRate*Δt)
    maxDepth = tree.depth

    # process the tree -
    depth_index_array = collect(range((maxDepth - 1),step=-1,stop=1))
    for depth_index in depth_index_array
        
        # update the tree -
        compute(tree.root, pup, pdown, DF, 1, depth_index)        
    end

    # return -
    return tree
end
# ============================================================================================

# --- PUBLIC METHODS ---------------------------------------------------------------------------------------- #
function build_ternary_price_tree(parameters::PSOptionKitPricingParameters)::PSTernaryPriceTree

    # TODO: checks -
    # ...

    # get parameters -
    baseAssetPrice = parameters.baseAssetPrice
    volatility = parameters.volatility
    timeToExercise = parameters.timeToExercise
    numberOfLevels = parameters.numberOfLevels

    # call helper method -
    return _build_ternary_price_tree(baseAssetPrice, volatility, timeToExercise, numberOfLevels)
end

function build_binary_price_tree(parameters::PSOptionKitPricingParameters)::PSBinaryPriceTree

    # TODO: checks -
    # ....

    
    # get parameters -
    baseAssetPrice = parameters.baseAssetPrice
    volatility = parameters.volatility
    timeToExercise = parameters.timeToExercise
    numberOfLevels = parameters.numberOfLevels

    # call helper method -
    return _build_binary_price_tree(baseAssetPrice, volatility, timeToExercise, numberOfLevels)
end

function option_contract_price(parameters::PSOptionKitPricingParameters; modelTreeType::Symbol = :binary, optionContractType::Symbol = :call, 
    earlyExercise::Bool = false)::(Union{PSResult{T}, Nothing} where T<:Any)

    # TODO: checks ...
    # ...

    # setup the price tree -
    priceTree = nothing
    if modelTreeType == :binary
    
        # build the pricing model -
        priceTree = build_binary_price_tree(parameters)

    elseif modelTreeType == :ternary
        
        # build a ternary price model -
        priceTree = build_ternary_price_tree(parameters)

    else
        # throw a unknown model type error -
        return PSResult{PSError}(PSError("unkown model: model type not supported"))
    end
    
    # compute the values on the tree -
    optionValueTree = nothing
    if (optionContractType == :call)
        optionValueTree = _build_call_option_intrinsic_value_tree(priceTree, parameters.strikePrice)
    elseif (optionContractType == :put)
        optionValueTree = _build_put_option_intrinsic_value_tree(priceTree, parameters.strikePrice)
    else
        # throw an unknown contract type -
        return PSResult{PSError}(PSError("unkown contract: contract type not supported"))
    end

    # compute -
    optionContractCostTree = _option_contract_price(priceTree, parameters.riskFreeRate, parameters.dividendRate)

    # setup the optionPrice -
    optionContractPrice = 0.0
    if (earlyExercise == false)
        optionContractPrice = optionContractCostTree.root.europeanOptionValue
    else
        optionContractPrice = optionContractCostTree.root.americanOptionValue
    end

    # return -
    return PSResult{Float64}(optionContractPrice)
end

function option_contract_price(assetPriceArray::Array{Float64,1}, parameters::PSOptionKitPricingParameters; modelTreeType::Symbol = :binary, optionContractType::Symbol = :call, 
    earlyExercise::Bool = false)::(Union{PSResult{T}, Nothing} where T<:Any)

    # checks -
    # ...

    # initialize -
    optionContractPriceArray = Array{Float64,1}()

    # Get base values from the properties struct -
    volatility = parameters.volatility
    timeToExercise = parameters.timeToExercise
    numberOfLevels = parameters.numberOfLevels
    strikePrice = parameters.strikePrice
    riskFreeRate = parameters.riskFreeRate
    dividendRate = parameters.dividendRate

    # main loop -
    for asset_price_value in assetPriceArray

        # create new options struct -
        optionsParameterStruct = PSOptionKitPricingParameters(asset_price_value, volatility, timeToExercise, numberOfLevels, strikePrice, riskFreeRate, dividendRate)

        # compute the price -
        result_object = option_contract_price(optionsParameterStruct; modelTreeType = modelTreeType, optionContractType = optionContractType, earlyExercise = earlyExercise)

        # check the type - if error, then return -
        if (typeof(result_object.value) == PSError)
            return result_object
        else

            # ok, so we seem to have a legit value. Grad the price, and cache in the array -
            value::Float64 = result_object.value    # should we check on the type?
            push!(optionContractPriceArray, value)
        end
    end
    
    # return -
    return PSResult{Array{Float64,1}}(optionContractPriceArray)
end

function multileg_option_contract_price(assetPriceArray::Array{Float64,1}, optionLegSet::Set{PSAbstractAsset}, parameters::PSOptionKitPricingParameters, intrinsicValueFunction::Function; 
    modelTreeType::Symbol = :binary, earlyExercise::Bool = false)::(Union{PSResult{T}, Nothing} where T<:Any)


    # checks -
    # ...

    # initialize -
    optionContractPriceArray = Array{Float64,1}()

    # Get base values from the properties struct -
    volatility = parameters.volatility
    timeToExercise = parameters.timeToExercise
    numberOfLevels = parameters.numberOfLevels
    strikePrice = parameters.strikePrice
    riskFreeRate = parameters.riskFreeRate
    dividendRate = parameters.dividendRate

    # main loop -
    for asset_price_value in assetPriceArray

        # create new options struct -
        optionsParameterStruct = PSOptionKitPricingParameters(asset_price_value, volatility, timeToExercise, numberOfLevels, strikePrice, riskFreeRate, dividendRate)

        # compute the price -
        result_object = multileg_option_contract_price(optionLegSet, optionsParameterStruct, intrinsicValueFunction; modelTreeType = modelTreeType, earlyExercise = earlyExercise)

        # check the type - if error, then return -
        if (typeof(result_object.value) == PSError)
            return result_object
        else

            # ok, so we seem to have a legit value. Grad the price, and cache in the array -
            value::Float64 = result_object.value    # should we check on the type?
            push!(optionContractPriceArray, value)
        end
    end

    # return -
    return PSResult{Array{Float64,1}}(optionContractPriceArray)
end

function multileg_option_contract_price(optionLegSet::Set{PSAbstractAsset}, parameters::PSOptionKitPricingParameters, intrinsicValueFunction::Function; 
    modelTreeType::Symbol = :binary, earlyExercise::Bool = false)::(Union{PSResult{T}, Nothing} where T<:Any)

     # TODO: checks ...
    # ...

    # setup the price tree -
    priceTree = nothing
    if modelTreeType == :binary
    
        # build the pricing model -
        priceTree = build_binary_price_tree(parameters)

    elseif modelTreeType == :ternary
        
        # build a ternary price model -
        priceTree = build_ternary_price_tree(parameters)

    else
        # throw a unknown model type error -
        return PSResult{PSError}(PSError("unkown model: model type not supported"))
    end

     # compute the values on the tree -
     # not sure how to do this ...
     optionValueTree = nothing
     if (optionContractType == :call)
         optionValueTree = _build_call_option_intrinsic_value_tree(priceTree,parameters.strikePrice)
     elseif (optionContractType == :put)
         optionValueTree = _build_put_option_intrinsic_value_tree(priceTree, parameters.strikePrice)
     else
         # throw an unknown contract type -
         return PSResult{PSError}(PSError("unkown contract: contract type not supported"))
     end
 
     # compute -
     optionContractCostTree = _option_contract_price(priceTree, parameters.riskFreeRate, parameters.dividendRate)
 
     # setup the optionPrice -
     optionContractPrice = 0.0
     if (earlyExercise == false)
         optionContractPrice = optionContractCostTree.root.europeanOptionValue
     else
         optionContractPrice = optionContractCostTree.root.americanOptionValue
     end
 
     # return -
     return PSResult{Float64}(optionContractPrice)
end
# ----------------------------------------------------------------------------------------------------------- #