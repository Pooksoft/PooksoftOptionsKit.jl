# abstract types -
abstract type PSAbstractVisualizationTheme end
abstract type PSAbstractLatticeModel end

# concrete types -
mutable struct PSBinaryPriceTreeNode <: PSAbstractAssetTreeNode

    # data -
    price::Float64
    left::Union{Nothing, PSBinaryPriceTreeNode}
    right::Union{Nothing, PSBinaryPriceTreeNode}
    
    intrinsicValueSet::Union{Nothing,Set{Float64}}
    totalOptionValue::Union{Nothing,Float64}
    
    # constructor -
    function PSBinaryPriceTreeNode()
        this = new()
    end
end

mutable struct PSTernaryPriceTreeNode <: PSAbstractAssetTreeNode

    # data -
    price::Float64
    left::Union{Nothing, PSTernaryPriceTreeNode}
    center::Union{Nothing, PSTernaryPriceTreeNode}
    right::Union{Nothing, PSTernaryPriceTreeNode}
    
    intrinsicValueSet::Union{Nothing,Set{Float64}}
    totalOptionValue::Union{Nothing,Float64}
    
    # constructor -
    function PSTernaryPriceTreeNode()
        this = new()
    end
end

struct PSTernaryPriceTree <: PSAbstractAssetTree

    # data -
    root::PSTernaryPriceTreeNode
    Δt::Float64
    U::Float64  # jump up
    C::Float64  # jump center (same)
    D::Float64  # jump down
    V::Float64  # volitility -
    depth::Int64

    function PSTernaryPriceTree(root::PSTernaryPriceTreeNode, Δt::Float64, U::Float64, C::Float64, D::Float64, V::Float64, depth::Int64)
        this = new(root, Δt, U, C, D, V, depth)
    end
end

struct PSBinaryPriceTree <: PSAbstractAssetTree

    # data -
    root::PSBinaryPriceTreeNode
    Δt::Float64
    U::Float64
    D::Float64
    depth::Int64

    function PSBinaryPriceTree(root::PSBinaryPriceTreeNode, Δt::Float64, U::Float64, D::Float64, depth::Int64)
        this = new(root, Δt, U, D, depth)
    end
end

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

mutable struct PSOptionKitPricingParameters

    # data -
    volatility::Float64
    timeToExercise::Float64
    numberOfLevels::Int64
    riskFreeRate::Float64
    dividendRate::Float64

    function PSOptionKitPricingParameters(volatility,timeToExercise,numberOfLevels,riskFreeRate,dividendRate)
        this = new(volatility,timeToExercise,numberOfLevels,riskFreeRate,dividendRate)
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
    timeToExercise::Int64
    riskFreeRate::Float64
    dividendRate::Float64

    function PSBinaryLatticeModel(volatility,timeToExercise,riskFreeRate,dividendRate)
        this = new(volatility,timeToExercise,riskFreeRate,dividendRate)
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