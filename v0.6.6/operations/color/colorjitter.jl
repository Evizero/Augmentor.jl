using Augmentor
using ImageShow, ImageCore

img_in = testpattern(RGB, ratio=0.5)

mosaicview(
    img_in,
    augment(img_in, ColorJitter(1.2, 0.3)),
    augment(img_in, ColorJitter(0.75, -0.2));
    fillvalue=colorant"white", nrow=1, npad=10
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

