![header](https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/readme/header.png)

A **fast** library for increasing the number of training images
by applying various transformations.

# Augmentor.jl's documentation

Augmentor is a real-time image augmentation library designed to
render the process of artificial dataset enlargement more
convenient, less error prone, and easier to reproduce. It offers
the user the ability to build a *stochastic image-processing
pipeline* (or simply *augmentation pipeline*) using image
operations as building blocks. In other words, an augmentation
pipeline is little more but a sequence of operations for which
the parameters can (but need not) be random variables, as the
following code snippet demonstrates.

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
using Augmentor, ImageCore, ImageMagick
using MLDatasets
using Random

# copied from operations/assets/gif.jl
function make_gif(img, pl, num_sample; random_seed=1337, kwargs...)
    fillvalue = oneunit(eltype(img[1]))

    init_frame = mosaicview(img; kwargs...)
    frames = map(1:num_sample-1) do _
        mosaicview(map(x->augment(x, pl), img)...; kwargs...)
    end

    frames = sym_paddedviews(fillvalue, init_frame, frames...)
    cat(frames..., dims=3)
end

pl = ElasticDistortion(6, scale=0.3, border=true) |>
     Rotate([10, -5, -3, 0, 3, 5, 10]) |>
     ShearX(-10:10) * ShearY(-10:10) |>
     CropSize(28, 28) |>
     Zoom(0.9:0.1:1.2)

n_samples, n_frames = 24, 10
imgs = [MNIST.convert2image(MNIST.traintensor(i)) for i in 1:n_samples]
preview = make_gif(imgs, pl, n_frames; nrow=1)

ImageMagick.save("mnist_preview.gif", RGB(1, 1, 1) .- preview; fps=3)
```

![mnist_preview](mnist_preview.gif)

The Julia version of **Augmentor** is engineered specifically for
high performance applications. It makes use of multiple
heuristics to generate efficient tailor-made code for the
concrete user-specified augmentation pipeline. In particular
Augmentor tries to avoid the need for any intermediate images,
but instead aims to compute the output image directly from the
input in one single pass.

For the Python version of Augmentor, you can find it [here](https://github.com/mdbloice/Augmentor)

## Where to begin?

If this is the first time you consider using Augmentor.jl for
your machine learning related experiments or packages, make sure
to check out the "Getting Started" section. There we list the
installation instructions and some simple hello world examples.

```@contents
Pages = ["gettingstarted.md"]
Depth = 2
```

## Introduction and Motivation

If you are new to image augmentation in general, or are simply
interested in some background information, feel free to take a
look at the following sections. There we discuss the concepts
involved and outline the most important terms and definitions.

```@contents
Pages = ["background.md"]
Depth = 2
```

In case you have not worked with image data in Julia before, feel
free to browse the following documents for a crash course on how
image data is represented in the Julia language, as well as how
to visualize it. For more information on image processing in
Julia, take a look at the documentation for the vast
[`JuliaImages`](https://juliaimages.github.io/stable/) ecosystem.

```@contents
Pages = ["images.md"]
Depth = 2
```

## User's Guide

As the name suggests, Augmentor was designed with image
augmentation for machine learning in mind. That said, the way the
library is implemented allows it to also be used for efficient
image processing outside the machine learning domain.

The following section describes the high-level user interface in
detail. In particular it focuses on how a (stochastic)
image-processing pipeline can be defined and then be applied to
an image (or a set of images). It also discusses how batch
processing of multiple images can be performed in parallel using
multi-threading.

```@contents
Pages = ["interface.md"]
Depth = 2
```

We mentioned before that an augmentation pipeline is just a
sequence of image operations. Augmentor ships with a number of
predefined operations, which should be sufficient to describe the
most commonly utilized augmentation strategies. Each operation is
represented as its own unique type. The following section
provides a complete list of all the exported operations and their
documentation.

```@contents
Pages = ["operations.md"]
Depth = 2
```

## Tutorials

Just like an image can say more than a thousand words, a simple
hands-on tutorial showing actual code can say more than many
pages of formal documentation.

The first step of devising a successful augmentation strategy is
to identify an appropriate set of operations and parameters. What
that means can vary widely, because the utility of each operation
depends on the dataset at hand (see [label-preserving
transformations](@ref labelpreserving) for an example). To that
end, we will spend the first tutorial discussing a simple but
useful approach to interactively explore and visualize the space
of possible parameters.

```@contents
Pages = [joinpath("generated", "mnist_elastic.md")]
Depth = 2
```

In the next tutorials we will take a close look at how we can
actually use Augmentor in combination with popular deep learning
frameworks. The first framework we will discuss will be
[Knet](https://github.com/denizyuret/Knet.jl). In particular we
will focus on adapting an already existing example to make use of
a (quite complicated) augmentation pipeline. Furthermore, this
tutorial will also serve to showcase the various ways that
augmentation can influence the performance of your network.

```@contents
Pages = [joinpath("generated", "mnist_knet.md")]
Depth = 2
```

```@eval
# Pages = [joinpath("generated", fname) for fname in readdir("generated") if splitext(fname)[2] == ".md"]
# Depth = 2
```

## Citing Augmentor

If you use Augmentor for academic research and wish to cite it,
please use the following paper.

Marcus D. Bloice, Christof Stocker, and Andreas Holzinger,
*Augmentor: An Image Augmentation Library for Machine Learning*,
arXiv preprint **arXiv:1708.04680**,
<https://arxiv.org/abs/1708.04680>, 2017.

## Indices

```@contents
Pages = ["indices.md"]
```
