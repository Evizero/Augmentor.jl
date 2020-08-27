# ---
# title: Scale
# cover: scale.gif
# ---

# Relatively resizing image

using Augmentor
using ImageShow, ImageCore
using Random

# In the case that only a single scale factor is specified, the
# operation will assume that the intention is to scale all
# dimensions uniformly by that factor.

img_in = testpattern(RGB, ratio=0.5)

mosaicview(
    img_in,
    augment(img_in, Scale(0.8)),
    augment(img_in, Scale(0.8, 1));
    
    fillvalue=colorant"white", nrow=1, npad=10
)

# It is also possible to pass some abstract vector(s) to the
# constructor, in which case Augmentor will randomly sample one of
# its elements every time the operation is applied.

Random.seed!(1337)
img_out = [augment(img_in, Scale(0.9:0.05:1.2)) for _ in 1:4]
mosaicview(img_out...; fillvalue=colorant"white", nrow=2)

# ## References

#md # ```@docs
#md # Scale
#md # ```

## save covers #src
using ImageMagick #src
include(joinpath("..", "assets", "utilities.jl")) #src
cover = make_gif(testpattern(RGB, ratio=0.5), Scale(0.9:0.1:1.5), 5) #src
ImageMagick.save("scale.gif", cover; fps=1) #src
