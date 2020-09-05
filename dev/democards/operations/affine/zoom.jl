using Augmentor
using ImageShow, ImageCore
using Random

img_in = testpattern(RGB, ratio=0.5)

mosaicview(
    img_in,
    augment(img_in, Zoom(1.3)),
    augment(img_in, Zoom(1.3, 1));
    fillvalue=colorant"white", nrow=1, npad=10
)

Random.seed!(1337)
img_out = [augment(img_in, Zoom(0.9:0.05:1.2)) for _ in 1:4]

mosaicview(img_out...; nrow=2)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

