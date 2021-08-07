# Getting Started

In this section we will provide a condensed overview of the
package. In order to keep this overview concise, we will not
discuss any background information or theory on the losses here
in detail.

## Installation

To install
[Augmentor.jl](https://github.com/Evizero/Augmentor.jl), start up
Julia and type the following code-snipped into the REPL. It makes
use of the native Julia package manger.

```julia
Pkg.add("Augmentor")
```

Additionally, for example if you encounter any sudden issues, or
in the case you would like to contribute to the package, you can
manually choose to be on the latest (untagged) version.

```julia
Pkg.develop("Augmentor")
```

## Example

The following code snippet shows how a stochastic augmentation
pipeline can be specified using simple building blocks that we
call "operations". In order to give the example some meaning, we
will use a real medical image from the publicly available [ISIC
archive](https://isic-archive.com/) as input. The concrete image
can be downloaded
[here](https://isic-archive.com/api/v1/image/5592ac599fc3c13155a57a85/thumbnail)
using their [Web API](https://isic-archive.com/api/v1).

```julia
julia> using Augmentor, ISICArchive

julia> img = get(ImageThumbnailRequest(id = "5592ac599fc3c13155a57a85"))
169×256 Array{RGB{N0f8},2}:
[...]

julia> pl = Either(1=>FlipX(), 1=>FlipY(), 2=>NoOp()) |>
            Rotate(0:360) |>
            ShearX(-5:5) * ShearY(-5:5) |>
            CropSize(165, 165) |>
            Zoom(1:0.05:1.2) |>
            Resize(64, 64)
6-step Augmentor.ImmutablePipeline:
 1.) Either: (25%) Flip the X axis. (25%) Flip the Y axis. (50%) No operation.
 2.) Rotate by θ ∈ 0:360 degree
 3.) Either: (50%) ShearX by ϕ ∈ -5:5 degree. (50%) ShearY by ψ ∈ -5:5 degree.
 4.) Crop a 165×165 window around the center
 5.) Zoom by I ∈ {1.0×1.0, 1.05×1.05, 1.1×1.1, 1.15×1.15, 1.2×1.2}
 6.) Resize to 64×64

julia> img_new = augment(img, pl)
64×64 Array{RGB{N0f8},2}:
[...]
```

```@eval
using Augmentor, ISICArchive
using ImageCore, ImageMagick
using Random

img = get(ImageThumbnailRequest(id = "5592ac599fc3c13155a57a85"))

pl = Either(1=>FlipX(), 1=>FlipY(), 2=>NoOp()) |>
     Rotate(0:360) |>
     ShearX(-5:5) * ShearY(-5:5) |>
     CropSize(165, 165) |>
     Zoom(1:0.05:1.2) |>
     Resize(64, 64)

# modified from operations/assets/gif.jl
function make_gif(img, pl, num_sample; post_op=identity, random_seed=1337)
    Random.seed!(random_seed)

    fillvalue = oneunit(eltype(img))
    frames = sym_paddedviews(
        fillvalue,
        post_op(img),
        [post_op(augment(img, pl)) for _ in 1:num_sample-1]...
    )
    cat(frames..., dims=3)
end

ImageMagick.save(joinpath("assets","isic_in.png"), img)
preview = make_gif(img, pl, 10)[:, :, 2:end]
ImageMagick.save(joinpath("assets", "isic_out.gif"), preview; fps=2)

nothing
```

The function `augment` will generate a single augmented image
from the given input image and pipeline. To visualize the effect
we compiled a few resulting output images into a GIF.

Input (`img`)                |   | Output (`img_new`)
:---------------------------:|:-:|:------------------------------:
![input](assets/isic_in.png) | → | ![output](assets/isic_out.gif)

## Segmentation example

Augmentor also provides a convenient interface for applying a stochastic
augmentation for images and their masks, which is useful for tasks of semantic
segmentation. The following snippet demonstrates how to use the interface. The
used image is derived from the [ISIC archive](https://isic-archive.com/).

```julia
julia> using Augmentor

julia> img, mask = # load image and its mask

julia> pl = Either(Rotate90(), FlipX(), FlipY()) |>
            Either(ColorJitter(), GaussianBlur(3))

julia> img_new, mask_new = augment(img => mask, pl)
```

```@eval
using Augmentor
using FileIO, ImageMagick, ImageCore
using Random

imgpath = joinpath("assets","segm_img.png")
maskpath = joinpath("assets","segm_mask.png")

img = load(imgpath)
mask = load(maskpath)

pl = Either(Rotate90(), FlipX(), FlipY()) |>
     Either(ColorJitter(), GaussianBlur(3))

# modified from operations/assets/gif.jl
function make_gif(img, mask, pl, num_sample; random_seed=1337)
    Random.seed!(random_seed)

    fillvalue = oneunit(eltype(img))
    frames = sym_paddedviews(
        fillvalue,
        hcat(img, mask),
        [hcat(augment(img => mask, pl)...) for _ in 1:num_sample-1]...
    )
    cat(frames..., dims=3)
end

preview = make_gif(img, mask, pl, 16)[:, :, 2:end]
ImageMagick.save(joinpath("assets", "segm_test.gif"), preview; fps=2)

nothing
```

The augmented images and masks are displayed in the following animation:

![output](assets/segm_test.gif)

## Getting Help

To get help on specific functionality you can either look up the
information here, or if you prefer you can make use of Julia's
native doc-system. The following example shows how to get
additional information on [`augment`](@ref) within Julia's REPL:

```julia
?augment
```

If you find yourself stuck or have other questions concerning the
package you can find us at gitter or the **Machine Learning**
domain on discourse.julialang.org

- [Julia ML on Gitter](https://gitter.im/JuliaML/chat)

- [Machine Learning on Julialang](https://discourse.julialang.org/c/domain/ML)

If you encounter a bug or would like to participate in the
development of this package come find us on Github.

- [Evizero/Augmentor.jl](https://github.com/Evizero/Augmentor.jl)
