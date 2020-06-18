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

function update_price_array!(priceArray::Array{Float64,1}, up::Float64, down::Float64)

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

function build_tree_node(priceArray::Array{Float64,1}, root::Union{Nothing, PSBinaryPriceTreeNode}, nodeIndex::Int64, maxCount::Int64)

    if (nodeIndex <= maxCount)
        
        @show (nodeIndex,maxCount)

        # setup -
        tmpNode = PSBinaryPriceTreeNode()
        tmpNode.price = priceArray[nodeIndex]
        
        # Put dummy values on the L and R nodes -
        tmpNode.left = nothing
        tmpNode.right = nothing

        # setup the root -
        root = tmpNode

        # insert L (down price)
        root.left = build_tree_node(priceArray, root.left, 2*(nodeIndex -1) + 2, maxCount)

        # insert R (up price)
        root.right = build_tree_node(priceArray, root.right, 2*(nodeIndex - 1) + 3, maxCount)
    end

    # return -
    return root
end

function build_binary_price_tree(basePrice::Float64, riskFreeRate::Float64, dividendRate::Float64, 
    volatility::Float64, timeToExercise::Float64, numberOfLevels::Int)

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
    update_price_array!(priceArray,U,D)

    # build the root node -
    root = PSBinaryPriceTreeNode()

    # assemble tree -
    root = build_tree_node(priceArray,root,1,number_of_elements)

    # return -
    return root
end