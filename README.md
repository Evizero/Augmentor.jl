![Augmentor](https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/header.png)

**Augmentor.jl** is the [Julia](http://julialang.org)
implementation for *Augmentor*. You can find the Python version
[here](https://github.com/mdbloice/Augmentor).

| **Package Status** | **Package Evaluator** | **Build Status**  |
|:------------------:|:---------------------:|:-----------------:|
| [![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](LICENSE.md) [![Documentation Status](https://img.shields.io/badge/docs-latest-blue.svg?style=flat)](http://augmentorjl.readthedocs.io/en/latest/?badge=latest) | [![Julia Pkg 0.5](http://pkg.julialang.org/badges/Augmentor_0.5.svg)](http://pkg.julialang.org/?pkg=Augmentor) [![Julia Pkg 0.6](http://pkg.julialang.org/badges/Augmentor_0.6.svg)](http://pkg.julialang.org/?pkg=Augmentor) | [![Travis Status](https://travis-ci.org/Evizero/Augmentor.jl.svg?branch=master)](https://travis-ci.org/Evizero/Augmentor.jl) [![AppVeyor status](https://ci.appveyor.com/api/projects/status/stfgx2856r8ckskw?svg=true)](https://ci.appveyor.com/project/Evizero/augmentor-jl) [![Coverage Status](https://coveralls.io/repos/github/Evizero/Augmentor.jl/badge.svg?branch=master)](https://coveralls.io/github/Evizero/Augmentor.jl?branch=master) |

Augmentor is an image-augmentation library designed to render
the process of artificial dataset enlargement more convenient,
less error prone, and easier to reproduce. This is achieved using
probabilistic transformation pipelines.

## Hello World

The following code snipped shows how a stochastic augmentation
pipeline can be specified using simple building blocks. To show
the effect we compiled a few resulting output images into a gif.
In order to give the example some meaning, we will use a real
medical image from the publicly available [ISIC
archive](https://isic-archive.com/) as input.

```julia
julia> using Augmentor, ISICArchive

julia> img = get(ImageThumbnailRequest(id = "5592ac599fc3c13155a57a85"))
# 169×256 Array{RGB{N0f8},2}:
# [...]

julia> pipeline = (
           Either(1=>FlipX(), 1=>FlipY(), 2=>NoOp()),
           Rotate(0:360),
           Either(ShearX(-5:5), ShearY(-5:5)),
           CropSize(165, 165),
           Zoom(1:0.05:1.2),
           Resize(64, 64)
       )
# 6-step Augmentor.Pipeline:
#  1.) Either: (25%) Flip the X axis. (25%) Flip the Y axis. (50%) No operation.
#  2.) Rotate by θ ∈ 0:360 degree
#  3.) Either: (50%) ShearX by ϕ ∈ -5:5 degree. (50%) ShearY by ψ ∈ -5:5 degree.
#  4.) Crop a 165×165 window around the center
#  5.) Zoom by I ∈ {1.0×1.0, 1.05×1.05, 1.1×1.1, 1.15×1.15, 1.2×1.2}
#  6.) Resize to 64×64

julia> img_new = augment(img, pipeline)
# 64×64 Array{RGB{N0f8},2}:
# [...]
```

Input (`img`)                       |   | Output (`img_new`)
:----------------------------------:|:-:|:------------------------------:
![input](https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/readme_1_in.png) | → | ![output](https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/readme_1_out.gif)


## Documentation

For a much more detailed treatment check out the **[latest
documentation](http://augmentorjl.readthedocs.io/en/latest/index.html)**.

Additionally, you can make use of Julia's native docsystem.
The following example shows how to get additional information
on `augment` within Julia's REPL:

```julia
?augment
```

## Installation

To install `Augmentor.jl`, start up Julia and type the following
code snipped into the REPL. It makes use of the native Julia
package manager. Once installed the Augmentor package can be
imported just as any other Julia package.

```julia
Pkg.clone("https://github.com/Evizero/Augmentor.jl.git")
using Augmentor
```

Additionally, for example if you encounter any sudden issues, you
can manually choose to be on the latest (untagged) development
version.

```julia
Pkg.checkout("Augmentor")
```

## License

This code is free to use under the terms of the MIT license.

## Acknowledgment

This package makes heavy use of the following packages in order
to provide it's main functionality. To see at full list of
utilized packages, please take a look at the REQUIRE file.

- [FugroRoames/CoordinateTransformations.jl](https://github.com/FugroRoames/CoordinateTransformations.jl)
- [JuliaImages/ImageTransformations.jl](https://github.com/JuliaImages/ImageTransformations.jl)
- [JuliaMath/Interpolations.jl](https://github.com/JuliaMath/Interpolations.jl)
- [JuliaArrays/IdentityRanges.jl](https://github.com/JuliaArrays/IdentityRanges.jl)

Note that this version `Augmentor.jl` is a complete rewrite of an
initial implementation that had the same name. The old
implementation is now located at
[AugmentorDeprecated.jl](https://github.com/Evizero/AugmentorDeprecated.jl).
