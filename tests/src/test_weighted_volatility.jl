using PooksoftOptionsKit
using DataFrames
using CSV

# load the F data set -
path_to_data_file = "$(pwd())/tests/data/F-E2020-09-18-T08-13-2020.csv"
F_data_set = CSV.read(path_to_data_file)

# what are the keys?
weightKey = Symbol("Open Int")
dataKey = Symbol("IV")

# compute -
result = compute_weighted_volatility(F_data_set,weightKey,dataKey)