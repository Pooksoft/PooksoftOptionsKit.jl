using PooksoftOptionsKit
using PyPlot
using Dates
using Distributions

# build -
function _setup(path_to_config_file::String)

    # initialize -
    lattice_model = nothing
    asset_set = nothing
    
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
path_to_design_file = "$(pwd())/tests/config/Call.json"
result = _setup(path_to_design_file)
problem_setup = nothing
if (isa(result.value,Exception) == false)
    problem_setup = result.value
end

# call to the greeks -
underlyingAssetPrice = 54.17
delta_value = 0.0
result = delta(problem_setup.assets,problem_setup.model,underlyingAssetPrice)
if (isa(result.value, Exception) == false)
    delta_value = result.value
end

# calculate theta -
theta_value = 0.0
result = theta(problem_setup.assets, problem_setup.model, underlyingAssetPrice)
if (isa(result.value, Exception) == false)
    theta_value = result.value
end

# calculate vega -
vega_value = 0.0
result = vega(problem_setup.assets, problem_setup.model, underlyingAssetPrice)
if (isa(result.value, Exception) == false)
    vega_value = result.value
end


# calculate rho -
rho_value = 0.0
result = rho(problem_setup.assets, problem_setup.model, underlyingAssetPrice)
if (isa(result.value, Exception) == false)
    rho_value = result.value
end