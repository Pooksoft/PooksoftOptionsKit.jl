using PooksoftOptionsKit
using PyPlot
using Dates
using Distributions

# build -
function _setup(path_to_config_file::String)

    # initialize -
    lattice_model = nothing
    asset_set = nothing
    asset_price_array = nothing
    data_array_at_exp = nothing
    
    # load the lattice model -
    result = build_simulation_lattice_data_structure(path_to_config_file)
    if (typeof(result.value) == PSError)
        return result
    else
        lattice_model = result.value
    end

    # load the asset set -
    result = build_simulation_asset_set(path_to_config_file)
    if (typeof(result.value) == PSError)
        return result
    else
        asset_set = result.value
    end

    # Setup tmp structure -
    named_tuple = (model=lattice_model,assets=asset_set)

    # return -
    return PSResult(named_tuple)
end

# setup -
path_to_design_file = "$(pwd())/tests/config/IronCondor-F.json"
result = _setup(path_to_design_file)
problem_setup = nothing
if (isa(result.value,Exception) == false)
    problem_setup = result.value
end