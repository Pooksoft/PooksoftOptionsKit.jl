# define constants here -
const path_to_package = dirname(pathof(@__MODULE__))

# packages -
using PyPlot
using Dates

# include my code -
include("./base/Types.jl")
include("./base/Checks.jl")
include("./base/Models.jl")
include("./base/Greeks.jl")
include("./base/Compute.jl")
include("./base/Volatility.jl")
