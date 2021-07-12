using Augmentor
using ImageShow, ImageCore

img_in = testpattern(RGB, ratio=0.5)

mosaicview(
    img_in,
    augment(img_in, GaussianBlur(3)),
    augment(img_in, GaussianBlur(5, 2.5));
    fillvalue=colorant"white", nrow=1, npad=10
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

