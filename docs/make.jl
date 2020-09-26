using PooksoftOptionsKit
using Documenter

# call to make docs -
makedocs(sitename="PooksoftOptionsKit",

    pages = [
        "index.md",
        "Option pricing models" => [
            "binomial.md"
        ],
        "Profit and loss simulations" => [
            "profit_and_loss.md"
        ]
    ]
)