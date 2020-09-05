using Augmentor
using ImageShow, ImageCore

img_in = testpattern(RGB, ratio=0.5)
img_out = augment(img_in, CropRatio()) # crop out a square window

mosaicview(img_in, img_out; nrow=1)

augment(img_in, RCropRatio())

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

