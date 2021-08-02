using Documenter, DemoCards
using Augmentor
using Random
using MLDatasets

try
    using ISICArchive
catch
    using Pkg
    Pkg.add(url="https://github.com/Evizero/ISICArchive.jl.git", rev="master")
    using ISICArchive
end

ENV["DATADEPS_ALWAYS_ACCEPT"] = true # MLDatasets

op_templates, op_theme = cardtheme("grid")
operations, operations_cb = makedemos("operations", op_templates)
examples_templates, examples_theme = cardtheme("list")
examples, examples_cb = makedemos("examples", examples_templates)

format = Documenter.HTML(edit_link = "master",
                         prettyurls = get(ENV, "CI", nothing) == "true",
                         assets = [
                             joinpath("assets", "favicon.ico"),
                             joinpath("assets", "style.css"),
                             op_theme,
                             examples_theme
                        ]
)

makedocs(
    modules = [Augmentor],
    sitename = "Augmentor.jl",
    authors = "Christof Stocker",
    # linkcheck = true,
    format = format,
    pages = [
        "Home" => "index.md",
        "gettingstarted.md",
        "Introduction and Motivation" => [
            "background.md",
            "images.md",
        ],
        "User's Guide" => [
            "interface.md",
            operations,
        ],
        "Tutorials" => examples,
        hide("Indices" => "indices.md"),
        "LICENSE.md",
    ],
    # doctest=:fix, # used to fix outdated doctest
)

operations_cb()
examples_cb()

deploydocs(repo = "github.com/Evizero/Augmentor.jl.git")
