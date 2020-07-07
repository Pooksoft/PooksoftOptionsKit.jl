mutable struct PSBinaryPriceTreeNode <: PSAbstractAssetTreeNode

    # data -
    price::Float64
    left::Union{Nothing, PSBinaryPriceTreeNode}
    right::Union{Nothing, PSBinaryPriceTreeNode}
    
    
    intrinsicValue::Union{Nothing,Float64}
    americanOptionValue::Union{Nothing,Float64}
    europeanOptionValue::Union{Nothing,Float64}
    
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
    
    intrinsicValue::Union{Nothing,Float64}
    americanOptionValue::Union{Nothing,Float64}
    europeanOptionValue::Union{Nothing,Float64}
    
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

struct PSOptionKitPricingParameters

    # data -
    baseAssetPrice::Float64
    volatility::Float64
    timeToExercise::Float64
    numberOfLevels::Int64
    strikePrice::Float64
    riskFreeRate::Float64
    dividendRate::Float64

    function PSOptionKitPricingParameters(baseAssetPrice,volatility,timeToExercise,numberOfLevels,strikePrice,riskFreeRate,dividendRate)
        this = new(baseAssetPrice,volatility,timeToExercise,numberOfLevels,strikePrice,riskFreeRate,dividendRate)
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

    function PSCallOptionContract(assetSymbol::String, expirationDate::Date, strikePrice::Float64, premimumValue::Float64, numberOfContracts::Int64; sense::Symbol=:buy)
        this = new(assetSymbol, strikePrice, expirationDate, premimumValue, numberOfContracts, sense)
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

    function PSPutOptionContract(assetSymbol::String, expirationDate::Date, strikePrice::Float64, premimumValue::Float64, numberOfContracts::Int64; sense::Symbol=:buy)
        this = new(assetSymbol, strikePrice, expirationDate, premimumValue, numberOfContracts, sense)
    end
end