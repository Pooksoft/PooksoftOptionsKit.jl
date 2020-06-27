struct PSResult{T}
    value::T
end

struct PSError <: Exception
    message::String
end

abstract type PSAbstractAsset end

mutable struct PSBinaryPriceTreeNode

    # data -
    price::Float64
    left::Union{Nothing, PSBinaryPriceTreeNode}
    right::Union{Nothing, PSBinaryPriceTreeNode}
    intrinsicValue::Union{Nothing,Float64}
    totalValue::Float64
    
    # constructor -
    function PSBinaryPriceTreeNode()
        this = new()
    end
end

mutable struct PSTernaryPriceTreeNode

    # data -
    price::Float64
    left::Union{Nothing, PSTernaryPriceTreeNode}
    center::Union{Nothing, PSTernaryPriceTreeNode}
    right::Union{Nothing, PSTernaryPriceTreeNode}
    intrinsicValue::Union{Nothing,Float64}
    totalValue::Float64
    
    # constructor -
    function PSTernaryPriceTreeNode()
        this = new()
    end
end

struct PSTernaryPriceTree

    # data -
    root::PSTernaryPriceTreeNode
    Δt::Float64
    U::Float64
    C::Float64
    D::Float64
    depth::Int64

    function PSTernaryPriceTree(root::PSTernaryPriceTreeNode, Δt::Float64, U::Float64, C::Float64, D::Float64, depth::Int64)
        this = new(root, Δt, U, C, D,depth)
    end
end

struct PSBinaryPriceTree

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