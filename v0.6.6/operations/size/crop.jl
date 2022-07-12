using Augmentor
using ImageShow, ImageCore
using OffsetArrays

img_in = testpattern(RGB, ratio=0.5)
img_out = augment(img_in, Crop(20:75,25:120))

mosaicview(img_in, img_out; fillvalue=colorant"white", nrow=1)

augment(img_in, Crop(20:75,25:120)) == augment(img_in, CropNative(20:75,25:120))

imgo_in = OffsetArray(img_in, -50, -50)
imgo_out = augment(imgo_in, Crop(20:75,25:120))
imgo_out_native = augment(imgo_in, CropNative(20:75,25:120))

(
    imgo_in[(first.(axes(imgo_in)) .+ (20, 25))...] == imgo_out[1, 1],
    imgo_in[20, 25] == imgo_out_native[1, 1]
)

mosaicview(
    augment(img_in, Rotate(30) |> Crop(axes(img_in))),
    augment(img_in, Rotate(30) |> CropNative(axes(img_in))),

    augment(img_in, ShearX(10) |> Crop(axes(img_in))),
    augment(img_in, ShearX(10) |> CropNative(axes(img_in)));

    fillvalue=colorant"white", rowmajor=true, nrow=2, npad=10
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

