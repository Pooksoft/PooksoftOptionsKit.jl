using PooksoftOptionsKit
using DataFrames
using CSV
using Dates

function load_actual_option_price_array(path_to_data_file::String, type::Symbol)::Array{Float64,2}

    # load -
    full_data_frame = CSV.read(path_to_data_file)

    # ok, so we need to extract the reqd cols -
    strike = Symbol("Strike")
    bid = Symbol("Bid")
    ask = Symbol("Ask")
    
    # find rows of type -
    idx_type = findall(x->x==String(type), full_data_frame[!,:Type])
    number_of_type_rows = length(idx_type)
    data_array = zeros(number_of_type_rows, 3)
    for (index, type_index) in enumerate(idx_type)
        
        data_array[index,1] = full_data_frame[type_index, strike]
        data_array[index,2] = full_data_frame[type_index, bid]
        data_array[index,3] = full_data_frame[type_index, ask]
    end
    
    # return -
    return data_array
end

function estimated_options_price_array()

    # setup the call test -
    stock_price = 54.17
    implied_volatility = 0.67
    DTE = (31.0/365.0)
    number_of_levels = 12
    strike_price_array = collect(range(45.0, step=1.0, stop=80.0))
    number_of_strike_prices = length(strike_price_array)
    risk_free_rate = 0.15 # this is in percent
    dividend_rate = 0.0 # this is in percent

    # initialize -
    estimated_price_array = zeros(number_of_strike_prices,2)

    # setup options calculation -
    amd_option_parameters = PSOptionKitPricingParameters(implied_volatility, DTE, number_of_levels, risk_free_rate, dividend_rate)

    # compute -
    for (index,strike_price) in enumerate(strike_price_array)

        # initialize -
        assetSet = Set{PSAbstractAsset}()
        
        # setup an amd call option -
        callOptionContract = PSCallOptionContract("AMD", Date(2020,6,25), strike_price, 0.0, 1; sense=:buy, contractMultiplier=1.0)
        push!(assetSet, callOptionContract)    
        
        # build the pricing tree -
        tree = build_ternary_price_tree(assetSet, amd_option_parameters, stock_price)

        # compute -
        result = option_contract_price(tree, amd_option_parameters)

        # grab - we should check the return type ... but for now ...
        estimated_price_array[index,1] = strike_price
        estimated_price_array[index,2] = result.value
    end

    return estimated_price_array
end

# compute the estimated prices -
estimated_price_array = estimated_options_price_array()

# load the data -
path_to_data_file = "$(pwd())/tests/data/AMD-31D.csv"
actual_price_array = load_actual_option_price_array(path_to_data_file, :Call)