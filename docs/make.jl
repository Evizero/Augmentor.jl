using Documenter, DemoCards
using Augmentor
using Random
using MLDatasets

ENV["DATADEPS_ALWAYS_ACCEPT"] = true # MLDatasets

op_templates, op_theme = cardtheme("grid")
operations, operations_cb = makedemos("operations", op_templates)

format = Documenter.HTML(edit_link = "master",
                         prettyurls = get(ENV, "CI", nothing) == "true",
                         assets = [
                             joinpath("assets", "favicon.ico"),
                             joinpath("assets", "style.css"),
                             op_theme
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
        # "Tutorials" => joinpath.("generated", ExampleWeaver.listmarkdown()),
        hide("Indices" => "indices.md"),
        "LICENSE.md",
    ]
)

operations_cb()

deploydocs(repo = "github.com/Evizero/Augmentor.jl.git")
