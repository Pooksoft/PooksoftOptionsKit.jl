using PooksoftOptionsKit

# setup movement function -
function movement(latticeModel::PSBinaryLatticeModel)
    
    # compute -
    volatility = latticeModel.volatility
    timeToExercise = latticeModel.timeToExercise
    riskFreeRate = latticeModel.riskFreeRate
    numberOfLevels = latticeModel.numberOfLevels

    # what is the dT?
    Δt = (timeToExercise/numberOfLevels)

    # compute u -
    U = exp(volatility * √Δt)
    D = 1 / U

    # return -
    return (U,D)
end



# setup the binary lattice model -
volatility = 0.54   
timeToExercise = (1.0/365.0)
riskFreeRate = 0.001
dividendRate = 0.0
numberOfLevels = 10
binary_lattice_model = PSBinaryLatticeModel(volatility, timeToExercise, riskFreeRate,dividendRate; numberOfLevels=numberOfLevels)

# compute prob distribution -
timeStepIndex = 3
latticeModel = binary_lattice_model
baseUnderlyingPrice = 47.25
movementFunction = movement
result = compute_underlying_price_distribution(timeStepIndex,latticeModel, baseUnderlyingPrice, movementFunction)
if (isa(result.value,Exception) == true)
    throw(result.value)
end
pd = result.value