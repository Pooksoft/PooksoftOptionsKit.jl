# define constants here -
const path_to_package = dirname(pathof(@__MODULE__))

# packages -
using PyPlot

# include my code -
include("./base/Types.jl")
include("./base/Compute.jl")