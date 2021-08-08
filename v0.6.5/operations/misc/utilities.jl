using Augmentor
using Random
Random.seed!(1337)

img_in = testpattern(RGB, ratio=0.5)
img_out = augment(img_in, Either(0.5=>NoOp(), 0.25=>FlipX(), 0.25=>FlipY()))

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

