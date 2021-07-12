# ---
# title: GaussianBlur
# cover: gaussianblur.gif
# description: blur the input image using a gaussian kernel
# ---

# [`GaussianBlur`](@ref) can be used to blur the input image using a gaussian
# kernel with a specified kernel size and standard deviation.

using Augmentor
using ImageShow, ImageCore

img_in = testpattern(RGB, ratio=0.5)

mosaicview(
    img_in,
    augment(img_in, GaussianBlur(3)),
    augment(img_in, GaussianBlur(5, 2.5));
    fillvalue=colorant"white", nrow=1, npad=10
)

# ## References

#md # ```@docs
#md # GaussianBlur
#md # ```


## save covers #src
using ImageMagick #src
using FileIO #src
include(joinpath("..", "assets", "utilities.jl")) #src
cover = make_gif(testpattern(RGB, ratio=0.5), GaussianBlur(5), 2) #src
ImageMagick.save("gaussianblur.gif", cover; fps=1) #src
