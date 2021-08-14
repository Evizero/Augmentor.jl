[![Augmentor](https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/readme/header.png)](https://evizero.github.io/Augmentor.jl/)

[![License][license-img]][license-url]
[![Docs-stable][docs-stable-img]][docs-stable-url]
[![Docs-dev][docs-dev-img]][docs-dev-url]
[![pkgeval][pkgeval-img]][pkgeval-url]
[![unittest][action-img]][action-url]
[![codecov][codecov-img]][codecov-url]

**Augmentor.jl** is a *fast* Julia library designed to make the process of
image augmentation more convenient, less error-prone, and easier to reproduce.
It offers a simple way to build flexible **augmentation pipelines**. For our
purposes, an augmentation pipeline can be understood as a sequence of
operations for which the parameters can (but need not) be random variables.

When augmenting, Augmentor.jl uses multiple heuristics to generate efficient
tailor-made code for the concrete user-specified augmentation pipeline. In
particular, Augmentor tries to avoid the need for any intermediate images and
aims to compute the output image directly from the input in one single pass.

## Overview

Augmentor.jl provides many augmentation operations such as rotations, flipping,
blurring, and more. See the
[documentation](https://evizero.github.io/Augmentor.jl/stable/operations/) for
the complete list of available operations.

The package uses the `|>` operator to **compose** operations into a pipeline.

Prepared pipelines are applied to images by calling one of the higher-level
functions: `augment`, `augment!`, or `augmentbatch!`.

The full documentation is available at
[evizero.github.io/Augmentor.jl/](https://evizero.github.io/Augmentor.jl/).

## Example

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

For more examples, see [the documentation](https://evizero.github.io/Augmentor.jl/).

## Contributing

Contributions are greatly appreciated!

To report a potential **bug** or propose a **new feature**, please file a *new
issue*. *Pull requests* are always welcome. However, to make sure the PR gets
accepted, it is generally preferred when it follows a particular issue to which
it refers.

## Citing Augmentor

If you use Augmentor for academic research and wish to cite it, please use the
following paper.

Marcus D. Bloice, Christof Stocker, and Andreas Holzinger, *Augmentor: An Image
Augmentation Library for Machine Learning*, arXiv preprint **arXiv:1708.04680**,
<https://arxiv.org/abs/1708.04680>, 2017.

## Acknowledgments

This package is inspired by a Python library of the same name available at
[github.com/mdbloice/Augmentor](https://github.com/mdbloice/Augmentor).

To provide most of the operations, Augmentor.jl makes heavy use of many
packages. To name a few:

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
