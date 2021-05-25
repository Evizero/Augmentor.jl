using Augmentor
using ImageShow, ImageCore
using Random
Random.seed!(0)
img_in = testpattern(RGB, ratio=0.5)

mosaicview(
    # deterministic transformation
    augment(img_in, ShearX(20)),
    augment(img_in, ShearY(20)),

    # random transformation
    augment(img_in, ShearX(-20:20)),
    augment(img_in, ShearY(-20:20));

    fillvalue=colorant"white", nrow=2, npad=10
)

mosaicview(
    augment(img_in, ShearX(10)),
    augment(img_in, ShearX(10) |> CropNative(axes(img_in)));
    fillvalue=colorant"white", nrow=1, npad=10
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

