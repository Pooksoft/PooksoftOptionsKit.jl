function function crr_am_put(S, K, r, σ, t, N)
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

function build_binomial_option_pricing_tree(basePrice::Float64, riskFreeRate::Float64, dividendRate::Float64, 
    volatility::Float64, timeToExercise::Float64, numberOfLevels::Int)

    # checks -
    # ....

    # compute delta T -
    dT = (timeToExercise/numberOfLevels)

    # compute up, down and p for each step -
    up = exp(volatility*sqrt(dT))
    down = exp(-1*volatility*sqrt(dT))
    pup = (exp((riskFreeRate - dividendRate)*dT) - down)/(up - down)
    pdown = 1 - pup

    # generate a root node -
    rootNode = PSBinomialPriceTreeNode()
    rootNode.price = basePrice

    # build the tree -
    currentNode = rootNode
    currentPrice = rootNode.price
    for tree_level_index = 1:numberOfLevels
        
        # get tree nodes at 

        # number of nodes -
        number_of_nodes = (2^tree_level_index)
        for node_index = 1:number_of_nodes
            
            # if is odd => up
            if (isodd(node_index) == true) 
                
                # new_node -
                new_node = PSBinomialPriceTreeNode()
                new_node.price = currentPrice*up

                # attach -
                currentNode.nextUpNode = new_node
            else
                
                # new_node -
                new_node = PSBinomialPriceTreeNode()
                new_node.price = currentPrice*down

                # attach -
                currentNode.nextDownNode = new_node
            end
        end
    end
    
    # return -
    return PSBinomialPricingTree(rootNode)
end