using Documenter, Augmentor

# Autogenerate documentation markdown and jupyter notebooks
# for all the scripts in the "examples/" subfolder.
include("exampleweaver.jl")
ExampleWeaver.weave(overwrite=false, execute=true)

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

srand(1337)
makedocs(
    modules = [Augmentor],
    clean = false,
    format = :html,
    assets = [
        joinpath("assets", "favicon.ico"),
        joinpath("assets", "style.css"),
    ],
    sitename = "Augmentor.jl",
    authors = "Christof Stocker",
    linkcheck = !("skiplinks" in ARGS),
    pages = Any[
        "Home" => "index.md",
        "gettingstarted.md",
        "Introduction and Motivation" => Any[
            "background.md",
            "images.md",
        ],
        "User's Guide" => Any[
            "interface.md",
            hide("operations.md", Any[joinpath("operations", fname) for fname in sort(readdir(joinpath(@__DIR__, "src", "operations")), lt = myless) if splitext(fname)[2] == ".md"]),
        ],
        "Tutorials" => joinpath.("generated", ExampleWeaver.listmarkdown()),
        hide("Indices" => "indices.md"),
        "LICENSE.md",
    ],
    html_prettyurls = !("local" in ARGS),
)

deploydocs(
    repo = "github.com/Evizero/Augmentor.jl.git",
    target = "build",
    julia = "0.6",
    deps = nothing,
    make = nothing,
)

# --------------------------------------------------------------------
# Post-process the generated HTML files of the examples/tutorials
# 1. Redirect "Edit on Github" link to the "examples/*.jl" file
# 2. Add a link in the top right corner to the Juypter notebook

build_dir = abspath(joinpath(@__DIR__, "build"))
for markdownname in ExampleWeaver.listmarkdown()
    name = splitext(markdownname)[1]
    htmlpath = joinpath(build_dir, "generated", name, "index.html")
    str_html = readstring(htmlpath)
    # replace github url to .jl file
    str_html = replace(
        str_html,
        r"docs/src/generated/([^.]*)\.md",
        s"examples/\1.jl"
    )
    # insert link to jupyter notebook
    str_html = replace(
        str_html,
        r"(<a class=\"edit-page\".*GitHub<\/a>)",
        s"\1<a class=\"edit-page\" href=\"___HREFPLACEHOLDER___\"><span class=\"fa fa-external-link\"> </span> Juypter Notebook</a>"
    )
    href = "https://nbviewer.jupyter.org/github/Evizero/Augmentor.jl/blob/gh-pages/generated/$(name * ".ipynb")"
    str_html = replace(str_html, "___HREFPLACEHOLDER___", href)
    # overwrite html file
    write(htmlpath, str_html)
end
