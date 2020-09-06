# --- PRIVATE METHODS --------------------------------------------------------------------------------------- #
function _build_call_contract_object(data::Dict{String,Any})

    # grab stuff from data -
    # "symbol":"AMD",
    # "type":"call",
    # "sense":"sell",
    # "strike_price":60.0,
    # "premium_value":1.50,
    # "number_of_contracts":1,
    # "expiration":"2020-08-07"

    symbol = data["ticker_symbol"]
    sense = data["sense"]
    strike_price = data["strike_price"]
    premium_value = data["premium_value"]
    number_of_contracts = data["number_of_contracts"]
    expiration_date_string = data["expiration"]
    contract_multuplier = data["contract_multiplier"]

    # TODO - check sense, is this legit?
    # TODO - check is date string formatting correct?

    # build -
    callOptionContract = PSCallOptionContract(symbol, Date(expiration_date_string), strike_price, premium_value, number_of_contracts; 
        sense=Symbol(sense), contractMultiplier=contract_multuplier)

    # return -
    return PSResult(callOptionContract)
end

function _build_put_contract_object(data::Dict{String,Any})

    symbol = data["ticker_symbol"]
    sense = data["sense"]
    strike_price = data["strike_price"]
    premium_value = data["premium_value"]
    number_of_contracts = data["number_of_contracts"]
    expiration_date_string = data["expiration"]
    contract_multiplier = data["contract_multiplier"]

    # TODO - check sense, is this legit?
    # TODO - check is date string formatting correct?

    # build -
    putOptionContract = PSPutOptionContract(symbol, Date(expiration_date_string), strike_price, premium_value, number_of_contracts; 
        sense=Symbol(sense),contractMultiplier=contract_multuplier)

    # return -
    return PSResult(putOptionContract)
end

function _build_equity_object(data::Dict{String,Any})

    symbol = data["ticker_symbol"]
    purchase_price = data["purchase_price_per_share"]
    number_of_shares = data["number_of_shares"]
    purchase_date_string = data["purchase_date"]

    # TODO - check sense, is this legit?
    # TODO - check is date string formatting correct?

    # build -
    equityObject = PSEquityAsset(ticker_symbol, purchase_price, number_of_shares, Date(purchase_date_string))

    # return -
    return PSResult(equityObject)
end
# ----------------------------------------------------------------------------------------------------------- #

# --- PUBLIC METHODS ---------------------------------------------------------------------------------------- #
function build_simulation_contract_set(simulation_dictionary::Dictionary{String,Any})::PSResult

    # TODO: check - do we have the correct keys?

    # grab the list of asset dictionaries -
    asset_dictionary_array = simulation_dictionary["contract_set_parameters"]
    for (index, asset_dictionary) in enumerate(asset_dictionary_array)
        
        # initialize -
        local result = nothing

        # ok, so lets grab data from the asset_dictionary, and build each asset type -
        type_string = asset_dictionary["type"]
        type_symbol = Symbol(type_string)
        if (type_symbol == :call)
            result = _build_call_contract_object(asset_dictionary)
        elseif (type_symbol == :put)
            result = _build_put_contract_object(asset_dictionary)
        elseif (type_symbol == :equity)
            result = _build_equity_object(asset_dictionary)
        end

        # grab -
        push!(asset_set, result.value)
    end

    # return -
    return PSResult(asset_set)
end

function build_simulation_contract_set(pathToSimulationFile::String)::PSResult

    # TODO: check - is this a legit path -

    # initialize -
    asset_set = Set{PSAbstractAsset}()

    # load the experimet file -
    simulation_dictionary = JSON.parsefile(pathToSimulationFile)

    # build the contract set -
    return build_simulation_contract_set(simulation_dictionary)
end

function build_simulation_lattice_data_structure(pathToSimulationFile::String)::PSResult

    # TODO: check - is this a legit path -

    # load the experimet file -
    simulation_dictionary = JSON.parsefile(pathToSimulationFile)

    # grab the lattice parameters -
    lattice_parameters = simulation_dictionary["underlying_model_parameters"]
    number_of_levels = lattice_parameters["number_of_levels"]
    implied_volatility = lattice_parameters["price_volatility"]
    days_to_expiration = lattice_parameters["days_to_expiration"]
    risk_free_rate = lattice_parameters["price_growth_rate"]
    dividend_rate = lattice_parameters["dividend_rate"]

    # build lattice object -
    option_parameters = PSOptionKitPricingParameters(implied_volatility, (days_to_expiration/365.0), number_of_levels, 
        risk_free_rate, dividend_rate)

    # return -
    return PSResult(option_parameters)
end

function build_simulation_price_array(pathToSimulationFile::String)::PSResult

    # TODO: check - is this a legit path -

    # load the experimet file -
    simulation_dictionary = JSON.parsefile(pathToSimulationFile)

    # grab the asset_price_array parameters -
    asset_price_parameters = simulation_dictionary["underlying_price_simulation_range"]
    price_start = asset_price_parameters["underlying_price_start"]
    price_stop = asset_price_parameters["underlying_price_stop"]
    number_of_steps = asset_price_parameters["number_of_steps"]

    # build the array -
    assetPriceArray = collect(range(price_start,stop=price_stop,length=number_of_steps))

    # return -
    return PSResult(assetPriceArray)
end
# ----------------------------------------------------------------------------------------------------------- #