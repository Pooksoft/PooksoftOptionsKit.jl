# --- PRIVATE METHODS --------------------------------------------------------------------------------------- #
function _build_ternary_tree_node(priceArray::Array{Float64,1}, root::Union{Nothing, PSTernaryPriceTreeNode}, nodeIndex::Int64, maxCount::Int64)

    if (nodeIndex <= maxCount)
        
        # setup -
        tmpNode = PSTernaryPriceTreeNode()
        tmpNode.price = priceArray[nodeIndex]
        
        # Put dummy values on the L and R nodes -
        tmpNode.left = nothing
        tmpNode.center = nothing
        tmpNode.right = nothing
        tmpNode.intrinsicValueSet = Set{Float64}()

        # setup the root -
        root = tmpNode

        # insert L (down price)
        root.left = _build_ternary_tree_node(priceArray, root.left, 3*(nodeIndex - 1) + 2, maxCount)

        # insert C (no change)
        root.center = _build_ternary_tree_node(priceArray, root.center, 3*(nodeIndex - 1) + 3, maxCount)

        # insert R (up price)
        root.right = _build_ternary_tree_node(priceArray, root.right, 3*(nodeIndex - 1) + 4, maxCount)
    end

    # return -
    return root
end

function _build_ternary_price_tree(basePrice::Float64, volatility::Float64, timeToExercise::Float64, 
    numberOfLevels::Int64)::PSTernaryPriceTree

    # TODO checks -
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
            priceArray[left_index] = down_price
        end

        if (center_index<=number_of_elements)
            priceArray[center_index] = center_price
        end

        if (right_index<=number_of_elements)
            priceArray[right_index] = up_price
        end
    end

    # build the root node -
    root = PSTernaryPriceTreeNode()
    root.intrinsicValueSet = Set{Float64}()

    # assemble tree root -
    root = _build_ternary_tree_node(priceArray,root,1,number_of_elements)

    # build tree -
    tree = PSTernaryPriceTree(root, Δt, U, C, D, volatility, numberOfLevels)

    # return -
    return tree
end

function _build_ternary_intrinsic_value_tree(tree::PSTernaryPriceTree, assetSet::Set{PSAbstractAsset})::PSTernaryPriceTree
    
    # update the root - walk through the tree, and calc the intrinsic values -
    for (index,asset) in enumerate(assetSet)
        _calculate_ternary_node_intrinsic_value(tree.root, asset)
    end

    # return the updated tree -
    return tree
end

function _calculate_ternary_node_intrinsic_value(node::PSTernaryPriceTreeNode, asset::PSAbstractAsset)

    # get the price on this node -
    price = node.price

    # calculate the intrinsic value -
    result = intrinsic_value(asset,price) # which iv function that gets called will be handled by multiple dispatch
    if (isa(result.value,Exception) == true)
        return result
    end
    iv = result.value.intrinsic_value

    # cache the iv in the node -
    push!(node.intrinsicValueSet,iv)

    # initialize total value -
    node.totalOptionValue = sum(node.intrinsicValueSet)

    # work on my kids -
    if (node.left !== nothing && node.right !== nothing)
        _calculate_ternary_node_intrinsic_value(node.left,asset)
        _calculate_ternary_node_intrinsic_value(node.center,asset) 
        _calculate_ternary_node_intrinsic_value(node.right,asset)    
    end
end

function _option_contract_price(tree::PSTernaryPriceTree, riskFreeRate::Float64, dividendRate::Float64; earlyExercise::Bool = false)

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
        _compute(tree.root, pup, pdown, DF, 1, depth_index)        
    end

    # return -
    return tree
end

function _compute(node::PSTernaryPriceTreeNode, probabilityUp::Float64, probabilityDown::Float64, discountFactor::Float64, 
    currentDepth::Int64, targetDepth::Int64; earlyExercise::Bool = false)

    # ok - are we at the target depth?
    if (currentDepth == targetDepth)

        # ok, we are at the depth we need, grab my kids and put them in the target set -
        L = node.left.totalOptionValue      # down
        R = node.right.totalOptionValue     # up
        C = node.center.totalOptionValue    # center
        totalValue = discountFactor*(probabilityUp*R+probabilityDown*L+(1-(probabilityUp+probabilityDown))*C)

        # ok, so if we allow early excercise, then we have an american option, otherwise european -
        if (earlyExercise == false)
            node.totalOptionValue = totalValue
        elseif (earlyExercise == true)
            node.totalOptionValue = max(totalValue, sum(node.intrinsicValueSet))
        end      
    else
        
        # ok, so we are *not* at the target depth -
        _compute(node.left, probabilityUp, probabilityDown, discountFactor, (currentDepth + 1), targetDepth; earlyExercise=earlyExercise)
        _compute(node.center, probabilityUp, probabilityDown, discountFactor, (currentDepth + 1), targetDepth; earlyExercise=earlyExercise)
        _compute(node.right, probabilityUp, probabilityDown, discountFactor, (currentDepth + 1), targetDepth; earlyExercise=earlyExercise)

    end
end
# ----------------------------------------------------------------------------------------------------------- #

# --- PUBLIC METHODS ---------------------------------------------------------------------------------------- #
function build_ternary_price_tree(assetSet::Set{PSAbstractAsset}, parameters::PSOptionKitPricingParameters, baseEquityPrice::Float64)::PSTernaryPriceTree

    # TODO: checks -
    # ...

    # get parameters -
    volatility = parameters.volatility
    timeToExercise = parameters.timeToExercise
    numberOfLevels = parameters.numberOfLevels

    # build the tree -
    tree = _build_ternary_price_tree(baseEquityPrice, volatility, timeToExercise, numberOfLevels)

    # compute the intrinsic_value on the tree nodes -
    tree = _build_ternary_intrinsic_value_tree(tree,assetSet)

    # call helper method -
    return tree
end

function option_contract_price(tree::PSTernaryPriceTree, parameters::PSOptionKitPricingParameters; earlyExercise::Bool = false)::(Union{PSResult{T}, Nothing} where T<:Any)

    # TODO: checks ...
    # ...

    # compute -
    optionContractCostTree = _option_contract_price(tree, parameters.riskFreeRate, parameters.dividendRate)

    # setup the optionPrice -
    optionContractPrice = optionContractCostTree.root.totalOptionValue
    
    # return -
    return PSResult{Float64}(optionContractPrice)
end
# ----------------------------------------------------------------------------------------------------------- #