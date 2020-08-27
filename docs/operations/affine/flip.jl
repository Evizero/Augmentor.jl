# ---
# title: Flip
# cover: flip.gif
# description: flip the input image horizontally or vertically
# ---

# [`FlipX`](@ref)/[`FlipY`](@ref) can be used to flip the input image horizontally/vertically.

using Augmentor
using ImageShow, ImageCore

img_in = testpattern(RGB, ratio=0.5)

mosaicview(
    img_in,
    augment(img_in, FlipX()),
    augment(img_in, FlipY());
    fillvalue=colorant"white", nrow=1, npad=10
)

# To perform a random flip, you can also pass the probablity to the constructor. For example, `FlipX(0.5)`
# flips the image with half chance.

# ## References

#md # ```@docs
#md # FlipX
#md # FlipY
#md # ```


## save covers #src
using ImageMagick #src
using FileIO #src
include(joinpath("..", "assets", "utilities.jl")) #src
cover = make_gif(testpattern(RGB, ratio=0.5), Either(FlipX(), FlipY()), 4) #src
ImageMagick.save("flip.gif", cover; fps=1) #src
