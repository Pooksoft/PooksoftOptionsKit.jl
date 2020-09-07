# define constants here -
const path_to_package = dirname(pathof(@__MODULE__))

# packages -
using PyPlot
using Dates
using Optim
using Reexport
using JSON
using ColorTypes
using DataFrames
@reexport using PookTradeBase
@reexport using PooksoftAssetModelingKit
@reexport using PooksoftAlphaVantageDataStore

# include my code -
include("./base/Types.jl")
include("./base/Checks.jl")
include("./base/Intrinsic.jl")
include("./base/Binary.jl")
include("./base/Ternary.jl")
include("./base/Greeks.jl")
include("./base/Compute.jl")
include("./base/Factory.jl")
include("./base/Volatility.jl")
include("./base/Utility.jl")
include("./base/Longstaff.jl")