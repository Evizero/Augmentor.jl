# ---
# title: Composition utilities
# cover: utilities.gif
# description: a set of helper operations that may be useful when compositing more complex augmentation workflow
# ---

# Aside from "true" operations that specify some kind of transformation, there are also a couple of
# special utility operations used for functionality such as stochastic branching.

using Augmentor
using Random
Random.seed!(1337)

img_in = testpattern(RGB, ratio=0.5)
img_out = augment(img_in, Either(0.5=>NoOp(), 0.25=>FlipX(), 0.25=>FlipY()))
#md nothing #hide

# ![](utilities.gif)

# ## References

#md # ```@docs
#md # NoOp
#md # Either
#md # CacheImage
#md # ```

## save covers #src
using ImageMagick #src
include(joinpath("..", "assets", "utilities.jl")) #src
pl = Either(ShearX(-5:5), ShearY(-5:5)) |> Rotate(-10:10) |> Either(NoOp(), FlipX(), FlipY()) |> CropNative(axes(img_in)) #src
cover = make_gif(img_in, pl, 10) #src
ImageMagick.save("utilities.gif", cover; fps=2) #src
