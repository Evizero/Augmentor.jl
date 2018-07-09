"""
    module ExampleWeaver

Uses the package `Weave` to generate `Documenter`-compatible
markdown files, as well as pre-executed Juypter notebooks, from
normal `.jl` scripts contained in the "examples/" subfolder of
the package.

The resulting markdown and notebook documents will be stored at
"docs/src/generated/" of the package. Thus it is advised to add
that folder to your **toplevel** `.gitignore` file. Do not put a
`.gitignore` file into "docs/src/generated" itself, as that would
affect the build documentation as well.

Note the following additions to the usual `Weave`-compatible
comment syntax that is supported for the ".jl" scripts in the
"examples/" folder:

- Lines that begin with `# md` will only be included
  in the markdown file (with the `# md` prefix removed)

- Lines that begin with `# jp` will only be included
  in the Jupyter notebook (with the `# jp` prefix removed)
"""
module ExampleWeaver
using Weave

export

    listexamples,
    listmarkdown,
    listnotebooks,

    weave_markdown,
    weave_notebook,
    weave

# --------------------------------------------------------------------

const EXAMPLES_DIR  = abspath(joinpath(@__DIR__, "..", "examples"))
const GENERATED_DIR = abspath(joinpath(@__DIR__, "src", "generated"))

function _listfiles(dir, ext, fullpath=false)
    fnames = filter(fname->splitext(fname)[2]==ext, readdir(dir))
    fullpath ? map(fname->joinpath(dir, fname), fnames) : fnames
end

listexamples(fullpath=false) = _listfiles(EXAMPLES_DIR, ".jl", fullpath)
listmarkdown(fullpath=false) = _listfiles(GENERATED_DIR, ".md", fullpath)
listnotebooks(fullpath=false) = _listfiles(GENERATED_DIR, ".ipynb", fullpath)

# --------------------------------------------------------------------

function weave_markdown(scriptname; overwrite=false)
    splitext(scriptname)[2] == ".jl" || return
    name = splitext(scriptname)[1]
    # define all required paths
    scriptpath = joinpath(EXAMPLES_DIR, scriptname)
    processed_scriptpath = joinpath(GENERATED_DIR, name * ".jl")
    jmdpath = joinpath(GENERATED_DIR, name * ".jmd")
    mdpath = joinpath(GENERATED_DIR, name * ".md")
    # if markdown file already exists, only overwrite if requested
    if isfile(mdpath) && !overwrite
        info("skipping markdown generation for \"$scriptname\" (file already exists)")
        return mdpath
    else
        info("generating markdown \"$(name*".md")\" for \"$scriptname\"")
        mkpath(GENERATED_DIR)
    end
    # load and pre-process script for markdown generation this
    # removes `# jp` and `#jp-only` lines and the `# md` prefix
    str_jl = readstring(scriptpath)
    str_jl = replace(str_jl, r"\n(#jp ).*", "")
    str_jl = replace(str_jl, r"\n.*(#jl-only)", "")
    str_jl = replace(str_jl, "\n#md ", "\n")
    write(processed_scriptpath, str_jl)
    # weave the .jl file into a .jmd file
    convert_doc(processed_scriptpath, jmdpath)
    # posprocess the .jmd and save it as .md for documenter
    str_md = readstring(jmdpath)
    str_md = replace(str_md, "```julia", "```@example $name")
    write(mdpath, str_md)
    # cleanup temporary files
    rm(processed_scriptpath)
    rm(jmdpath)
    # return path to final .md file
    mdpath
end

function weave_notebook(scriptname; overwrite=false, execute=true)
    splitext(scriptname)[2] == ".jl" || return
    name = splitext(scriptname)[1]
    # define all required paths
    scriptpath = joinpath(EXAMPLES_DIR, scriptname)
    processed_scriptpath = joinpath(GENERATED_DIR, name * ".jl")
    jppath = joinpath(GENERATED_DIR, name * ".ipynb")
    # if notebook file already exists, only overwrite if requested
    if isfile(jppath) && !overwrite
        info("skipping notebook generation for \"$scriptname\" (file already exists)")
        return jppath
    else
        info("generating notebook \"$(name*".ipynb")\" for \"$scriptname\"")
        mkpath(GENERATED_DIR)
    end
    # load and pre-process script for notebook generation this
    # removes `# md` and `#jp-only` lines and the `# jp` prefix
    str_jl = readstring(scriptpath)
    str_jl = replace(str_jl, r"\n(#md ).*", "")
    str_jl = replace(str_jl, r"\n.*(#jl-only)", "")
    str_jl = replace(str_jl, "\n#jp ", "\n")
    # additionally we slightly tweak the look of the references
    str_jl = replace(str_jl, r"\[\^(.*)\]:", s"**\1**:") # references
    str_jl = replace(str_jl, r"\[\^(.*)\]", s"[\1]") # citations
    write(processed_scriptpath, str_jl)
    # weave the .jl file into a .ipynb file
    convert_doc(processed_scriptpath, jppath)
    # execute notebook
    if execute
        sleep(1)
        info("executing and overwrite notebook \"$(name*".ipynb")\"")
        run(`jupyter-nbconvert --ExecutePreprocessor.timeout=-1 --to notebook --execute $(abspath(jppath)) --output $(name * ".ipynb")`)
    end
    # cleanup temporary files
    rm(processed_scriptpath)
    # return path to final .md file
    jppath
end

# --------------------------------------------------------------------

function weave(scriptname; overwrite=false, execute=true)
    md = weave_markdown(scriptname; overwrite=overwrite)
    jp = weave_notebook(scriptname; overwrite=overwrite, execute=execute)
    md, jp
end

function weave(; kw...)
    mds = String[]; jps = String[]
    for scriptname in listexamples()
        md, jp = weave(scriptname; kw...)
        push!(mds, md)
        push!(jps, jp)
    end
    mds, jps
end

end # module
