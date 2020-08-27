# ---
# title: CropRatio
# cover: cropratio.gif
# ---

# Crop centered window to fit given aspect ratio

using Augmentor
using ImageShow, ImageCore

img_in = testpattern(RGB, ratio=0.5)
img_out = augment(img_in, CropRatio()) # crop out a square window

mosaicview(img_in, img_out; nrow=1)

# `RCropRatio` is a random version that randomly choose a crop center -- not necessarily the center
# of the input image.

augment(img_in, RCropRatio())
#md nothing #hide

# ![](cropratio.gif)

# ## Reference

#md # ```@docs
#md # CropRatio
#md # RCropRatio
#md # ```


## save covers #src
using ImageMagick #src
using FileIO #src
include(joinpath("..", "assets", "utilities.jl")) #src
cover = make_gif(img_in, RCropRatio(), 5) #src
ImageMagick.save("cropratio.gif", cover; fps=1) #src
