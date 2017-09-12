![header](https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/readme/header.png)

A **fast** library for increasing the number of training images
by applying various transformations.

# Augmentor.jl's documentation

Augmentor is a real-time image augmentation library designed to
render the process of artificial dataset enlargement more
convenient, less error prone, and easier to reproduce. It offers
the user the ability to build a stochastic augmentation pipeline
using simple building blocks. In other words, a stochastic
augmentation pipeline is simply a sequence of operations for
which the parameters can (but need not) be random variables as
the following code snippet demonstrates.

```@repl
using Augmentor
pl = ElasticDistortion(6, scale=0.3, border=true) |>
     Rotate([10, -5, -3, 0, 3, 5, 10]) |>
     ShearX(-10:10) * ShearY(-10:10) |>
     CropSize(28, 28) |>
     Zoom(0.9:0.1:1.2)
```

Such a pipeline can then be used for sampling. Here we use the
first few examples of the [MNIST
database](http://yann.lecun.com/exdb/mnist/).

```@eval
# I can't use Reel.jl, because the way it stores the tmp pngs
# causes the images to be upscaled too much.
using Augmentor, MLDatasets, Images, Colors
using PaddedViews, OffsetArrays
srand(1337)

pl = ElasticDistortion(6, scale=0.3, border=true) |>
     Rotate([10, -5, -3, 0, 3, 5, 10]) |>
     ShearX(-10:10) * ShearY(-10:10) |>
     CropSize(28, 28) |>
     Zoom(0.9:0.1:1.2)

md_lbls = String[]
md_imgs = String[]
for i in 1:24
    input = MNIST.convert2image(MNIST.traintensor(i))
    imgs = [augment(input, pl) for j in 1:20]
    insert!(imgs, 1, first(imgs)) # otherwise loop isn't smooth
    fnames = map(imgs) do img
        tpath = tempname() * ".png"
        save(tpath, img)
        tpath
    end
    args = reduce(vcat, [[fname, "-delay", "1x4", "-alpha", "deactivate"] for fname in fnames])
    convert = strip(readstring(`which convert`))
    outname = joinpath("assets", "idx_mnist_$i.gif")
    run(`$convert $args $outname`)
    push!(md_lbls, "`$(MNIST.trainlabels(i))`")
    push!(md_imgs, "[![mnist $i]($outname)](@ref mnist)")
end
tbl = string(
    join(md_lbls, " | "), "\n",
    join(map(_->"---", md_lbls), "|"), "\n",
    join(md_imgs, " | "), "\n",
)
# Markdown.parse(tbl)
Markdown.parse(join(md_imgs, " "))
```

The Julia version of Augmentor is engineered specifically for
high performance applications. It makes use of multiple
heuristics to generate efficient tailor-made code for the
concrete user-specified augmentation pipeline. In particular
Augmentor tries to avoid the need for any intermediate images,
but instead aims to compute the output image directly from the
input in one single pass.

## Where to begin?

If this is the first time you consider using Augmentor.jl for
your machine learning related experiments or packages, make sure
to check out the "Getting Started" section. There we list the
installation instructions and some simple hello world examples.

```@contents
Pages = ["gettingstarted.md"]
Depth = 3
```

**Augmentor.jl** is the [Julia](https://julialang.org) package
for Augmentor. You can find the Python version
[here](https://github.com/mdbloice/Augmentor).

## Introduction and Motivation

If you are new to image augmentation in general, or are simply
interested in some background information, feel free to take a
look at the following sections. There we discuss the concepts
involved and outline the most important terms and definitions.

```@contents
Pages = ["background.md"]
Depth = 3
```

In case you have not worked with image data in Julia before, feel
free to browse the following documents for a crash course on how
image data is represented in the Julia language, as well as how
to visualize it.

```@contents
Pages = ["images.md"]
Depth = 3
```

## User's Guide

Augmentor provides a number of already implemented functionality.
The following section provides a complete list of all the
exported operations and their documentation.

```@contents
Pages = ["operations.md"]
Depth = 2
```

## Tutorials

```@contents
Pages = [joinpath("generated", fname) for fname in readdir("generated") if splitext(fname)[2] == ".md"]
Depth = 2
```

## Indices and tables

```@index
```
