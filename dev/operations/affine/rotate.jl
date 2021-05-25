using Augmentor
using ImageShow, ImageCore
using Random
Random.seed!(0)

img_in = testpattern(RGB, ratio=0.5)
mosaicview(
    img_in,

    # deterministic rotation
    augment(img_in, Rotate(45)),

    # random rotation
    augment(img_in, Rotate(-45:45));
    fillvalue=colorant"white", nrow=1, npad=10
)

mosaicview(
    augment(img_in, Rotate(45)),
    augment(img_in, Rotate(45) |> CropNative(axes(img_in)));
    nrow=1, npad=10
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

