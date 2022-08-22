using Documenter
using Bruno

makedocs(
    sitename = "Bruno",
    format = Documenter.HTML(),
    modules = [Bruno]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/USU-Analytics-Solution-Center/Bruno.jl"
)
