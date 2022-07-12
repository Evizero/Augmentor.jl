using Augmentor
using Random
using Statistics: mean

Random.seed!(1337)

DecreaseContrast = MapFun(pixel -> pixel / 2)
IncreaseBrightness = AggregateThenMapFun(img -> mean(img),
                                         (pixel, M) -> pixel + M / 5)

img_in = testpattern(RGB, ratio=0.5)
img_out = augment(img_in, DecreaseContrast |> IncreaseBrightness)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

