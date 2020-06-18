struct PSResult{T}
    value::T
end

struct PSError <: Exception
    message::String
end

abstract type PSAbstractAsset end

mutable struct PSBinomialPriceTreeNode

    # data -
    price::Float64
    nextUpNode::Union{Nothing, PSBinomialPriceTreeNode}
    nextDownNode::Union{Nothing, PSBinomialPriceTreeNode}

    # constructor -
    function PSBinomialPriceTreeNode()
        this = new()
    end
end

struct PSBinomialPricingTree
    root::PSBinomialPriceTreeNode
    function PSBinomialPricingTree(root::PSBinomialPriceTreeNode)
        this = new(root)
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