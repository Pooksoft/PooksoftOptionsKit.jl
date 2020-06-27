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

function calculate_call_node_value(node::PSBinaryPriceTreeNode,strikePrice::Float64)

    # get the price -
    price = node.price
    
    # calculate the intrinsicValue -
    node.intrinsicValue = max((price - strikePrice),0)
    node.totalValue = max((price - strikePrice),0)      # we'll update this later -

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

        # ok, we are at the depth we need, grab my kids and put them in the target set -
        L = node.left.totalValue     # down
        R = node.right.totalValue     # up
        totalValue = discountFactor*(probability*R+(1.0 - probability)*L)
        node.totalValue = totalValue
    else
        
        # ok, so we are *not* at the target depth -
        compute(node.left, probability, discountFactor, (currentDepth + 1), targetDepth)
        compute(node.right, probability, discountFactor, (currentDepth + 1), targetDepth)
    end
end

# --- PUBLIC METHODS ---------------------------------------------------------------------------------------- #
function build_call_option_intrinsic_value_tree(tree::PSBinaryPriceTree, strikePrice::Float64)::PSBinaryPriceTree
    
    # update the root - walk through the tree, and calc the intrinsic values -
    calculate_call_node_value(tree.root, strikePrice)

    # return the updated tree -
    return tree
end

function build_put_option_intrinsic_value_tree(tree::PSBinaryPriceTree, strikePrice::Float64)::PSBinaryPriceTree
    
    # update the root - walk through the tree, and calc the intrinsic values -
    calculate_put_node_value(tree.root, strikePrice)

    # return the updated tree -
    return tree
end

function build_ternary_price_tree(basePrice::Float64, volatility::Float64, timeToExercise::Float64, 
    numberOfLevels::Int64)::PSTernaryPriceTreeNode

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
    tree = PSTernaryPriceTree(root, Δt, U, C, D, numberOfLevels)

    # return -
    return root
end

function build_binary_price_tree(basePrice::Float64, volatility::Float64, timeToExercise::Float64, 
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

function option_contract_price(tree::PSBinaryPriceTree, riskFreeRate::Float64, dividendRate::Float64)

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

# ----------------------------------------------------------------------------------------------------------- #