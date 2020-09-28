# --- PRIVATE METHODS --------------------------------------------------------------------------------------- #
# ----------------------------------------------------------------------------------------------------------- #

# --- PUBLIC METHODS ---------------------------------------------------------------------------------------- #
function compute_naked_put_seller_trade_table(assetSet::Set{PSAbstractAsset}, strikePriceArray::Array{Float64,1}, itmProbabilityArray::Array{Float64,1},
    contractPriceArray::Array{Float64,1}, underlyingPrice::Float64)::PSResult

    # TODO: need to check to make sure the arrays have the correct data e.g., no negative entries
    # assume for now - ok

    # TODO: excerciseThreshold is between 0,1
    # assume for now - ok

    # initialize -
    excerciseProbabilityArray = Array{Float64,1}()
    creditsArray = Array{Float64,1}()
    debitArray = Array{Float64,1}()
    expectedValueArray = Array{Float64,1}()
    buyerPLArray = Array{Float64,1}()
    accountBalance = Array{Float64,1}()

    # compute data for the trade table -
    for (index,strike) in enumerate(strikePriceArray)
        
        # what is the probability of success for this trade?
        prob_of_excercise = itmProbabilityArray[index]
        push!(excerciseProbabilityArray,prob_of_excercise)

        # credits -
        credit_value = 100*(contractPriceArray[index])
        push!(creditsArray,credit_value)

        @show (strike,contractPriceArray[index],credit_value)

        # buyer P/L -
        result = intrinsic_value(assetSet,underlyingPrice)
        if (isa(result.value, Exception) == true)
            return result
        end
        iv_value = result.value
        buyer_profit_loss_value = -1*credit_value + 100*iv_value
        push!(buyerPLArray,buyer_profit_loss_value)

        # debit -
        debit_value = 0.0
        if (buyer_profit_loss_value>0)
            debit_value = -100*strike            
        end
        push!(debitArray,debit_value)

        # compute the seller account balance -
        balance = credit_value + debit_value + 100*(underlyingPrice - strike)
        push!(accountBalance,balance)

        # expected return -
        expected_return = (1 - prob_of_excercise)*(debit_value) + (prob_of_excercise)*credit_value
        push!(expectedValueArray,expected_return)
    end

    # setup the DataFrame -
    df = DataFrame(strike=strikePriceArray,probability_ITM=excerciseProbabilityArray,
        credit=creditsArray,debit=debitArray,balance=accountBalance, buyer=buyerPLArray,expected=expectedValueArray)

    # return -
    return PSResult{DataFrame}(df)
end
# ----------------------------------------------------------------------------------------------------------- #