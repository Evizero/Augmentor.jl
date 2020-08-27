# ---
# title: Resize
# cover: resize.gif
# ---

# Set the static size of the image

using Augmentor
using ImageShow, ImageCore

img_in = testpattern(RGB, ratio=0.5)

mosaicview(
    img_in,
    augment(img_in, Resize(240, 320));
    fillvalue=colorant"white", nrow=1, npad=10
)


# ## References

#md # ```@docs
#md # Resize
#md # ```

## save covers #src
using ImageMagick #src
include(joinpath("..", "assets", "utilities.jl")) #src
cover = make_gif(testpattern(RGB, ratio=0.5), Resize(240, 320), 2) #src
ImageMagick.save("resize.gif", cover; fps=1) #src
