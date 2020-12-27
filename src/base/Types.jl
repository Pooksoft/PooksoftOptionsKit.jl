# abstract types -
abstract type PSAbstractVisualizationTheme end
abstract type PSAbstractLatticeModel end

struct PSEquityAsset <: PSAbstractAsset

    # data -
    assetSymbol::String
    purchasePricePerShare::Float64
    numberOfShares::Int64
    purchaseDate::Date
    
    function PSEquityAsset(assetSymbol::String, purchasePricePerShare::Float64, numberOfShares::Int64, purchaseDate::Date)
        this = new(assetSymbol, purchasePricePerShare, numberOfShares, purchaseDate)
    end
end

struct PSCallOptionContract <: PSAbstractAsset

    # data -
    assetSymbol::String
    strikePrice::Float64
    expirationDate::Date
    premimumValue::Float64
    numberOfContracts::Int64
    sense::Symbol
    contractMultiplier::Float64

    function PSCallOptionContract(assetSymbol::String, expirationDate::Date, strikePrice::Float64, premimumValue::Float64, numberOfContracts::Int64; 
            sense::Symbol=:buy, contractMultiplier::Float64 = 100.0)
        
            this = new(assetSymbol, strikePrice, expirationDate, premimumValue, numberOfContracts, sense, contractMultiplier)
    end
end

struct PSPutOptionContract <: PSAbstractAsset

    # data -
    assetSymbol::String
    strikePrice::Float64
    expirationDate::Date
    premimumValue::Float64
    numberOfContracts::Int64
    sense::Symbol
    contractMultiplier::Float64

    function PSPutOptionContract(assetSymbol::String, expirationDate::Date, strikePrice::Float64, premimumValue::Float64, numberOfContracts::Int64; 
            sense::Symbol=:buy, contractMultiplier::Float64 = 100.0)

        this = new(assetSymbol, strikePrice, expirationDate, premimumValue, numberOfContracts, sense, contractMultiplier)
    end
end

struct LocalExpectationRegressionModel 
    
    a0::Float64
    a1::Float64
    a2::Float64
    a3::Float64

    function LocalExpectationRegressionModel(a0,a1,a2,a3)
        this = new(a0,a1,a2,a3)
    end
end

mutable struct PSBinaryLatticeModel <: PSAbstractLatticeModel

    # data -
    volatility::Float64
    timeToExercise::Float64
    riskFreeRate::Float64
    dividendRate::Float64
    numberOfLevels::Int64

    function PSBinaryLatticeModel(volatility,timeToExercise,riskFreeRate,dividendRate; numberOfLevels = 10)
        this = new(volatility,timeToExercise,riskFreeRate,dividendRate, numberOfLevels)
    end
end

mutable struct PSTernaryLatticeModel <: PSAbstractLatticeModel

    # data -
    volatility::Float64
    timeToExercise::Int64
    riskFreeRate::Float64
    dividendRate::Float64

    function PSTernaryLatticeModel(volatility,timeToExercise,riskFreeRate,dividendRate)
        this = new(volatility,timeToExercise,riskFreeRate,dividendRate)
    end
end