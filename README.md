[![Augmentor](https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/readme/header.png)](https://evizero.github.io/Augmentor.jl/)

[![License][license-img]][license-url]
[![Docs-stable][docs-stable-img]][docs-stable-url]
[![Docs-dev][docs-dev-img]][docs-dev-url]
[![pkgeval][pkgeval-img]][pkgeval-url]
[![unittest][action-img]][action-url]
[![codecov][codecov-img]][codecov-url]

A **fast** Julia library for increasing the number of training
images by applying various transformations.

Augmentor is a real-time image augmentation library designed to
render the process of artificial dataset enlargement more
convenient, less error prone, and easier to reproduce. It offers
the user the ability to build a *stochastic image-processing
pipeline* -- which we will also refer to as *augmentation
pipeline* -- using image operations as building blocks. For our
purposes, an augmentation pipeline can be understood as a
sequence of operations for which the parameters can (but need
not) be random variables.

```julia
julia> pl = ElasticDistortion(6, scale=0.3, border=true) |>
            Rotate([10, -5, -3, 0, 3, 5, 10]) |>
            ShearX(-10:10) * ShearY(-10:10) |>
            CropSize(28, 28) |>
            Zoom(0.9:0.1:1.2)
5-step Augmentor.ImmutablePipeline:
 1.) Distort using a smoothed and normalized 6×6 grid
 2.) Rotate by θ ∈ [10, -5, -3, 0, 3, 5, 10] degree
 3.) Either: (50%) ShearX by ϕ ∈ -10:10 degree. (50%) ShearY by ψ ∈ -10:10 degree.
 4.) Crop a 28×28 window around the center
 5.) Zoom by I ∈ {0.9×0.9, 1.0×1.0, 1.1×1.1, 1.2×1.2}

julia> augment(img, pl)
```

![](https://evizero.github.io/Augmentor.jl/dev/mnist_preview.gif)

The Julia version of Augmentor is engineered specifically for
high performance applications. It makes use of multiple
heuristics to generate efficient tailor-made code for the
concrete user-specified augmentation pipeline. In particular
Augmentor tries to avoid the need for any intermediate images,
but instead aims to compute the output image directly from the
input in one single pass.

**Augmentor.jl** is the [Julia](http://julialang.org)
implementation for Augmentor. The Python version of the same name
is available [here](https://github.com/mdbloice/Augmentor).

## Package Overview

Augmentor.jl provides:

* predefined augmentation operations, e.g., `FlipX`
* `|>` operator to compose operations into a pipeline
* higher-lvel functions (`augment`, `augment!` and `augmentbatch!`) that works on a pipeline and image(s).

Check the [documentation](https://evizero.github.io/Augmentor.jl/stable/operations/) for a full list of operations.

## Citing Augmentor

If you use Augmentor for academic research and wish to cite it,
please use the following paper.

Marcus D. Bloice, Christof Stocker, and Andreas Holzinger,
*Augmentor: An Image Augmentation Library for Machine Learning*,
arXiv preprint **arXiv:1708.04680**,
<https://arxiv.org/abs/1708.04680>, 2017.

## Acknowledgments

This package makes heavy use of the following packages in order
to provide it's main functionality. To see at full list of
utilized packages, please take a look at the [REQUIRE](./REQUIRE)
file.

- [FugroRoames/CoordinateTransformations.jl](https://github.com/FugroRoames/CoordinateTransformations.jl)
- [JuliaImages/ImageTransformations.jl](https://github.com/JuliaImages/ImageTransformations.jl)
- [JuliaMath/Interpolations.jl](https://github.com/JuliaMath/Interpolations.jl)
- [JuliaArrays/IdentityRanges.jl](https://github.com/JuliaArrays/IdentityRanges.jl)


[license-img]: https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat
[license-url]: LICENSE.md
[pkgeval-img]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/A/Augmentor.svg
[pkgeval-url]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/report.html
[action-img]: https://github.com/Evizero/Augmentor.jl/workflows/Unit%20test/badge.svg
[action-url]: https://github.com/Evizero/Augmentor.jl/actions
[codecov-img]: https://codecov.io/github/Evizero/Augmentor.jl/coverage.svg?branch=master
[codecov-url]: https://codecov.io/github/Evizero/Augmentor.jl?branch=master
[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://Evizero.github.io/Augmentor.jl/stable
[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://Evizero.github.io/Augmentor.jl/dev
