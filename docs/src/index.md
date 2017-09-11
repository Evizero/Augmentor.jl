![header](https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/readme/header.png)

```@eval
using Augmentor, Images
pattern = imresize(testpattern(), (240, 320))
save("assets/testpattern.png", pattern)
```

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
pipeline = Rotate([-5, -3, 0, 3, 5]) |> CropSize(64, 64) |> Zoom(1:0.1:1.2)
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
