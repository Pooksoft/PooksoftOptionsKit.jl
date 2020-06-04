function is_sense_legit(testSense::Symbol)::Bool
    
    # we allow buy and sell operations -
    approvedSet = Set{Symbol}()
    push!(approvedSet,:buy)
    push!(approvedSet,:sell)

    # check - is the testSense a member of the approvedSet?
    if (in(testSense,approvedSet) == true)
        return true
    end

    return false
end

function is_postive_value(value::T where T<:Number)::Bool
    
    # we should have only positive values -
    if (sign(value)==1.0 || sign(value) == 1)
        return true
    end

    return false
end