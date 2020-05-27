struct PSResult{T}
    value::T
end

struct PSError <: Exception
    message::String
end

abstract type PSAbstractOptionContract end

struct PSCallOptionContract <: PSAbstractOptionContract

    # data -
    assetSymbol::String
    strikePrice::Float64
    expirationDate::Date
    premimumValue::Float64

    function PSCallOptionContract(assetSymbol::String, expirationDate::Date, strikePrice::Float64, premimumValue::Float64; sense::Symbol=:buy)
        this = new(assetSymbol, strikePrice, expirationDate, premimumValue)
    end
end

struct PSPutOptionContract <: PSAbstractOptionContract

    # data -
    assetSymbol::String
    strikePrice::Float64
    expirationDate::Date
    premimumValue::Float64
    sense::Symbol

    function PSPutOptionContract(assetSymbol::String, expirationDate::Date, strikePrice::Float64, premimumValue::Float64; sense::Symbol=:buy)
        this = new(assetSymbol, strikePrice, expirationDate, premimumValue, sense)
    end
end