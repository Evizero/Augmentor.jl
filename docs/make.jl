using Documenter, Augmentor

makedocs(
    modules = [Augmentor],
    clean = false,
    format = :html,
    assets = [
        "assets/favicon.ico",
        "assets/style.css",
    ],
    sitename = "Augmentor.jl",
    authors = "Christof Stocker",
    linkcheck = !("skiplinks" in ARGS),
    pages = Any[
        "Home" => "index.md",
        "gettingstarted.md",
        "background.md",
        "images.md",
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
