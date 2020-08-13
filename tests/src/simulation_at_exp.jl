using PooksoftOptionsKit
using PyPlot
using Dates
using Distributions

# simulation logic -
function simulate(pathToSimulationFile::String, currentClose::Float64)

    # initialize -
    lattice_model = nothing
    asset_set = nothing
    asset_price_array = nothing
    data_array_at_exp = nothing
    prob_array = Array{Float64,1}()

    # load the lattice model -
    result = build_simulation_lattice_data_structure(pathToSimulationFile)
    if (typeof(result.value) == PSError)
        return result.value
    else
        lattice_model = result.value
    end
    
    # load the asset set -
    result = build_simulation_asset_set(pathToSimulationFile)
    if (typeof(result.value) == PSError)
        return result.value
    else
        asset_set = result.value
    end

    # load asset price array -
    result = build_simulation_price_array(pathToSimulationFile)
    if (typeof(result.value) == PSError)
        return result.value
    else
        asset_price_array = result.value
    end

    # run simulation at expiration -
    # compute -
    result = compute_option_profit_and_loss_at_expiration(asset_set, asset_price_array)
    if (typeof(result.value) == PSError)
        return result.value
    else
        data_array_at_exp = result.value
    end

    # check - are we in the money?
    iv = lattice_model.volatility
    d = Laplace(current_close,iv)
    for value in asset_price_array
        prob = 1 - cdf(d,value)
        push!(prob_array,prob)
    end
    

    # return -
    return (data_array_at_exp, prob_array)
end

# setup -
current_close = 7.23
path_to_design_file = "$(pwd())/tests/config/IronCondor.json"
(data_array_at_exp,pa) = simulate(path_to_design_file, current_close)