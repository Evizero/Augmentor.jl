using Documenter, Augmentor

using Weave
input_dir = joinpath(@__DIR__, "..", "examples")
output_dir = joinpath(@__DIR__, "src", "generated")
mkpath(output_dir)
new_md_files = []
for fname in readdir(input_dir)
    splitext(fname)[2] == ".jl" || continue;
    name = splitext(fname)[1]
    inpath = joinpath(input_dir, fname)
    doc_inpath = joinpath(output_dir, name * ".jl")
    str_md = replace(readstring(inpath), r"\n(#jp ).*\n", "\n")
    str_md = replace(str_md, "\n#md ", "\n")
    write(doc_inpath, str_md)
    outpath_jmd = joinpath(output_dir, name * ".jmd")
    outpath_md = joinpath(output_dir, name * ".md")
    convert_doc(doc_inpath, outpath_jmd)
    str_md = replace(readstring(outpath_jmd), "```julia", "```@example $name")
    rm(doc_inpath)
    rm(outpath_jmd)
    write(outpath_md, str_md)
    push!(new_md_files, joinpath("generated", name * ".md"))
end

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
            hide("operations.md", Any[joinpath("operations", fname) for fname in sort(readdir(joinpath(@__DIR__, "src", "operations"))) if splitext(fname)[2] == ".md"]),
        ],
        "Tutorials" => Any[new_md_files...],
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
