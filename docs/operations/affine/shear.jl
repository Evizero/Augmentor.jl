# ---
# title: Shear
# cover: shear.gif
# description: shear the input image horizontally or vertically
# ---

# [`ShearX`](@ref)/[`ShearY`](@ref) can be used to shear the input image horizontally/vertically.
# The input to the constructor can be a scalar or a vector. In the case of a vector, the transformation
# will be a stochastic process.

using Augmentor
using ImageShow, ImageCore
using Random
Random.seed!(0)
img_in = testpattern(RGB, ratio=0.5)

mosaicview(
    ## deterministic transformation
    augment(img_in, ShearX(20)),
    augment(img_in, ShearY(20)),

    ## random transformation
    augment(img_in, ShearX(-20:20)),
    augment(img_in, ShearY(-20:20));

    fillvalue=colorant"white", nrow=2, npad=10
)

# Note that the output image size will be changed after transformation, [`CropNative`](@ref) can be
# particalually useful to preserve the image size.

mosaicview(
    augment(img_in, ShearX(10)),
    augment(img_in, ShearX(10) |> CropNative(axes(img_in)));
    fillvalue=colorant"white", nrow=1, npad=10
)

# ## References

#md # ```@docs
#md # ShearX
#md # ShearY
#md # ```

## save covers #src
using ImageMagick #src
include(joinpath("..", "assets", "utilities.jl")) #src
cover = make_gif(testpattern(RGB, ratio=0.5), Either(ShearX(-10:10), ShearY(-10:10)), 5) #src
ImageMagick.save("shear.gif", cover; fps=1) #src
