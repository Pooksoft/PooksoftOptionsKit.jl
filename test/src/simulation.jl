using PooksoftOptionsKit
using PyPlot
using Dates
using Distributions

# simulation logic -
function simulate(pathToSimulationFile::String)

    # initialize -
    lattice_model = nothing
    asset_set = nothing
    asset_price_array = nothing
    data_array_at_exp = nothing
    
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

    # main loop -
    number_of_time_steps = length(asset_price_array)
    data_array = zeros(number_of_time_steps,2)
    for (index,asset_price) in enumerate(asset_price_array)

        # build the pricing tree -
        tree = build_ternary_price_tree(asset_set, lattice_model, asset_price)
    
        # compute -
        local result = option_contract_price(tree, lattice_model)
    
        # grab -
        data_array[index,1] = asset_price
        data_array[index,2] = result.value
    end

    # run simulation at expiration -
    # compute -
    result = compute_option_profit_and_loss_at_expiration(asset_set, asset_price_array)
    if (typeof(result.value) == PSError)
        return result.value
    else
        data_array_at_exp = result.value
    end

    # return -
    return (data_array, data_array_at_exp)
end

# setup -
path_to_design_file = "$(pwd())/tests/config/IronCondor.json"
(data_array, data_array_at_exp) = simulate(path_to_design_file)

# make a plot from the simulation -
