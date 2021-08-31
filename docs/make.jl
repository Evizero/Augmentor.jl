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

format = Documenter.HTML(edit_link = "master",
                         prettyurls = get(ENV, "CI", nothing) == "true",
                         assets = [
                             joinpath("assets", "favicon.ico"),
                             joinpath("assets", "style.css"),
                             op_theme
                        ]
)

About = "Introduction" => "index.md"

GettingStarted = "gettingstarted.md"

UserGuide = "User's guide" => [
        "interface.md",
        operations
    ]

DevGuide = "Developer's guide" => [
        "devguide/wrappers.md",
        "devguide/pipeline.md",
        "devguide/operations.md"
    ]

Examples = "Examples" => [
        "examples/flux.md"
    ]

License = "License" => "license.md"

PAGES = [
    About,
    GettingStarted,
    UserGuide,
    DevGuide,
    Examples,
    License
    ]

makedocs(
    modules = [Augmentor],
    sitename = "Augmentor.jl",
    authors = "Christof Stocker",
    format = format,
    checkdocs = :exports,
    pages = PAGES
)

operations_cb()

deploydocs(repo = "github.com/Evizero/Augmentor.jl.git")
