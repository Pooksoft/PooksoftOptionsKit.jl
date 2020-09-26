using PooksoftOptionsKit
using Documenter

# call to make docs -
makedocs(sitename="PooksoftOptionsKit",

    pages = [
        "index.md",
        "Option price models" => [
            "binary.md"
        ],
        "Profit and loss simulations" => [
            "profit_and_loss.md"
        ]
    ]
)