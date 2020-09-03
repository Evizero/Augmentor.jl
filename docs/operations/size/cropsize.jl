# ---
# title: CropSize
# cover: cropsize.gif
# ---

# Crop centered window to given size

using Augmentor
using ImageShow, ImageCore

img_in = testpattern(RGB, ratio=0.5)
img_out = augment(img_in, CropSize(70, 70)) # crop out a square window

mosaicview(img_in, img_out; nrow=1, npad=10)

# `RCropSize` is a random version that randomly choose a crop center -- not necessarily the center
# of the input image.

augment(img_in, CropSize(70, 70))
#md nothing #hide

# ![](cropsize.gif)

# ## Reference

#md # ```@docs
#md # CropSize
#md # RCropSize
#md # ```


## save covers #src
using ImageMagick #src
using FileIO #src
include(joinpath("..", "assets", "utilities.jl")) #src
cover = make_gif(testpattern(RGB, ratio=0.5), RCropSize(70, 70), 5) #src
ImageMagick.save("cropsize.gif", cover; fps=1) #src
