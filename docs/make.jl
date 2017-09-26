using Documenter, Augmentor, MLDatasets

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
    # md version
    str_md = replace(readstring(inpath), r"\n(#jp ).*", "")
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
    # jp version
    str_jp = replace(readstring(inpath), r"\n(#md ).*", "")
    str_jp = replace(str_jp, r"\[\^(.*)\]:", s"**\1**:") # references
    str_jp = replace(str_jp, r"\[\^(.*)\]", s"[\1]") # citations
    str_jp = replace(str_jp, "\n#jp ", "\n")
    write(doc_inpath, str_jp)
    outpath_jp = joinpath(output_dir, name * ".ipynb")
    convert_doc(doc_inpath, outpath_jp)
end

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
        "Tutorials" => Any[new_md_files...],
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
