# ---
# title: ColorJitter
# cover: colorjitter.gif
# description: Adjust contrast and brightness of an image
# ---

# [`ColorJitter`](@ref) can be used to adjust the contrast and brightness of an input image.

using Augmentor
using ImageShow, ImageCore

img_in = testpattern(RGB, ratio=0.5)

mosaicview(
    img_in,
    augment(img_in, ColorJitter(1.2, 0.3)),
    augment(img_in, ColorJitter(0.75, -0.2));
    fillvalue=colorant"white", nrow=1, npad=10
)

# ## References

#md # ```@docs
#md # ColorJitter
#md # ```

## save covers #src
using ImageMagick #src
using FileIO #src
include(joinpath("..", "assets", "utilities.jl")) #src
cover = make_gif(testpattern(RGB, ratio=0.5), ColorJitter(), 4) #src
ImageMagick.save("colorjitter.gif", cover; fps=1) #src
