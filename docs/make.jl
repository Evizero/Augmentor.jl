using Documenter, Augmentor
using Images
using Random

# Define the documentation order of the operations. The whole
# purpose of this vector is literally just to dictate in what
# chronological order the operations are documented.
op_fnames = [
    "flipx",
    "flipy",
    "rotate90",
    "rotate270",
    "rotate180",
    "rotate",
    "shearx",
    "sheary",
    "scale",
    "zoom",
    "elasticdistortion",
    "crop",
    "cropnative",
    "cropsize",
    "cropratio",
    "rcropratio",
    "resize",
    "converteltype",
    "mapfun",
    "aggmapfun",
    "splitchannels",
    "combinechannels",
    "permutedims",
    "reshape",
    "noop",
    "cacheimage",
    "either",
]
dict_order = Dict(fname * ".md" => i for (i, fname) in enumerate(op_fnames))
myless(a, b) = dict_order[a] < dict_order[b]

# --------------------------------------------------------------------

Random.seed!(1337)
format = Documenter.HTML(edit_link = "master",
                         prettyurls = get(ENV, "CI", nothing) == "true",
                         assets = [
                             joinpath("assets", "favicon.ico"),
                             joinpath("assets", "style.css")
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
            hide("operations.md", Any[joinpath("operations", fname) for fname in sort(readdir(joinpath(@__DIR__, "src", "operations")), lt = myless) if splitext(fname)[2] == ".md"]),
        ],
        # "Tutorials" => joinpath.("generated", ExampleWeaver.listmarkdown()),
        hide("Indices" => "indices.md"),
        "LICENSE.md",
    ]
)

deploydocs(repo = "github.com/Evizero/Augmentor.jl.git")
