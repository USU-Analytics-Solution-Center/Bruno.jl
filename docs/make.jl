using Documenter
using Bruno

const _PAGES = [
    "Introduction" => ["index.md", "installation.md"],
    "Tutorials" => [
        "Getting started" => [
            "tutorials/getting_started/introduction.md",
            "tutorials/getting_started/getting_started_with_julia.md",
            "tutorials/getting_started/getting_started_with_Bruno.md"
        ],
        "Simulating data" => [
            "tutorials/get_data/inputs.md",
            "tutorials/get_data/output.md"
        ],
        "Making financial instruments" => [
            "tutorials/fin_inst/base_asset.md",
            "tutorials/fin_inst/derivatives.md"
        ],
        "Pricing instruments" => [
            "tutorials/pricing/derivatives.md",
            "tutorials/pricing/futures.md"
        ],
        "Simulating hedges" => [
            "tutorials/hedge/options.md",
            "tutorials/hedge/futures.md"
        ]
    ],
    "Manual" => [
        "manual/types.md",
        "manual/data_generators.md",
        "manual/pricing_models.md",
        "manual/hedge_simulate.md"
    ],
    "API Reference" => [
        "reference/types.md",
        "reference/data_generators.md",
        "reference/pricing_models.md",
        "reference/hedge_simulate.md"
    ]
]


makedocs(
    sitename = "Bruno",
    modules = [Bruno],
    doctest = true,
    pages = _PAGES,
    format = Documenter.HTML(
        sidebar_sitename = true,
        prettyurls = get(ENV, "CI", nothing) == "true"
        )
)

# Automatic deployment to gh-pages through github on pull request
deploydocs(
    repo = "github.com/USU-Analytics-Solution-Center/Bruno.jl.git",
    versions = nothing
)
