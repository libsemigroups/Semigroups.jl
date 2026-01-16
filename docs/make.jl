using Documenter
using Semigroups  # your package

makedocs(
    sitename = "Semigroups.jl",
    modules = [Semigroups],
    format = Documenter.HTML(),
    pages = [
        "Home" => "index.md"
        "Data-structures" => ["Elements" => ["Transformations" => ["data-structures/elements/transformations/transf.md"]]]
        "Main Algorithms" => "main-algorithms/index.md"
    ],
    draft = true,
    warnonly = true
)
