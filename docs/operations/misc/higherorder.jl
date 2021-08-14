# ---
# title: Higher-order functions
# description: a set of helper opeartions that allow applying any function
# ---

# These operations are useful to perform an operation that is not explicitly
# defined in Augmentor.

using Augmentor
using Random
using Statistics: mean

Random.seed!(1337)

DecreaseContrast = MapFun(pixel -> pixel / 2)
IncreaseBrightness = AggregateThenMapFun(img -> mean(img),
                                         (pixel, M) -> pixel + M / 5)

img_in = testpattern(RGB, ratio=0.5)
img_out = augment(img_in, DecreaseContrast |> IncreaseBrightness)

# ## References

#md # ```@docs
#md # MapFun
#md # AggregateThenMapFun
#md # ```

