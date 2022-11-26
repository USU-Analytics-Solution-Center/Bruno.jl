using Documenter
using Bruno

const _PAGES = [
    "Introduction" => ["index.md"],
    "Tutorials" => [
        "Simulating Data" =>
            ["tutorials/get_data/get_data.md"],
        "Making Financial Instruments" => [
            "tutorials/fin_inst/base_asset.md",
            "tutorials/fin_inst/derivatives.md",
        ],
        "Strategy Testing" =>
            ["tutorials/strategy/options.md", "tutorials/strategy/widgets.md"],
    ],
    "Manual" => [
        "manual/types.md",
        "manual/data_generators.md",
        "manual/pricing_models.md",
        "manual/hedge_simulate.md",
    ],
    "API Reference" => [
        "reference/types.md",
        "reference/data_generators.md",
        "reference/pricing_models.md",
        "reference/hedge_simulate.md",
    ],
]


makedocs(
    sitename = "Bruno",
    modules = [Bruno],
    doctest = true,
    pages = _PAGES,
    format = Documenter.HTML(
        sidebar_sitename = true,
        prettyurls = get(ENV, "CI", nothing) == "true",
    ),
)

# Automatic deployment to gh-pages through github on pull request
deploydocs(
    repo = "github.com/USU-Analytics-Solution-Center/Bruno.jl.git",
    versions = nothing,
)
