using Augmentor
using ImageShow, ImageCore

img_in = testpattern(RGB, ratio=0.5)
img_out = augment(img_in, CropSize(70, 70)) # crop out a square window

mosaicview(img_in, img_out; nrow=1, npad=10)

augment(img_in, CropSize(70, 70))

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

