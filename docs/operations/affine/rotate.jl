# ---
# title: Rotate
# cover: rotate.gif
# description: rotate image anticlockwise
# ---

# The type [`Rotate`](@ref) defines a generic anticlockwise rotation operation around the center
# of the image. It is also possible to pass some abstract vector to the constructor, in which case
# Augmentor will randomly sample one of its elements every time the operation is applied.

using Augmentor
using ImageShow, ImageCore
using Random
Random.seed!(0)

img_in = testpattern(RGB, ratio=0.5)
mosaicview(
    img_in,

    ## deterministic rotation
    augment(img_in, Rotate(45)), 

    ## random rotation
    augment(img_in, Rotate(-45:45));
    fillvalue=colorant"white", nrow=1, npad=10
)

# Note that the output image size will be changed after rotation, [`CropNative`](@ref) can be particalually
# useful to preserve the image size.

mosaicview(
    augment(img_in, Rotate(45)),
    augment(img_in, Rotate(45) |> CropNative(axes(img_in)));
    nrow=1, npad=10
)

# Rotation by some special degree (e.g.,90, 180 and 270) can be handled more efficiently without interpolation.
# Compared to `Rotate(90)`, it is recommended to use [`Rotate90`](@ref) when possible. [`Rotate180`](@ref) and
# [`Rotate270`](@ref) are available, too.

# ## References

#md # ```@docs
#md # Rotate
#md # Rotate90
#md # Rotate180
#md # Rotate270
#md # ```

## save covers #src
using ImageMagick #src
include(joinpath("..", "assets", "utilities.jl")) #src
cover = make_gif(testpattern(RGB, ratio=0.5), Rotate(-20:20), 5) #src
ImageMagick.save("rotate.gif", cover; fps=1) #src
