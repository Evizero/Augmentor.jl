# ---
# title: Zoom
# cover: zoom.gif
# ---

# Scale without resize

using Augmentor
using ImageShow, ImageCore
using Random

# In the case that only a single Zoom factor is specified, the
# operation will assume that the intention is to Zoom all
# dimensions uniformly by that factor.

img_in = testpattern(RGB, ratio=0.5)

mosaicview(
    img_in,
    augment(img_in, Zoom(1.3)),
    augment(img_in, Zoom(1.3, 1));
    fillvalue=colorant"white", nrow=1, npad=10
)

# It is also possible to pass some abstract vector(s) to the
# constructor, in which case Augmentor will randomly sample one of
# its elements every time the operation is applied.

Random.seed!(1337)
img_out = [augment(img_in, Zoom(0.9:0.05:1.2)) for _ in 1:4]

mosaicview(img_out...; nrow=2)

# ## References

#md # ```@docs
#md # Zoom
#md # ```

## save covers #src
using ImageMagick #src
include(joinpath("..", "assets", "utilities.jl")) #src
cover = make_gif(testpattern(RGB, ratio=0.5), Zoom(0.9:0.1:1.5), 5) #src
ImageMagick.save("zoom.gif", cover; fps=1) #src
