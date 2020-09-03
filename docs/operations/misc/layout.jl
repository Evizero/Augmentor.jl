# ---
# title: Colorant conversion and channel layout
# cover: layout.gif
# description: a set of commonly used basic operations that wrapped by Augmentor
# ---

# Augmentor has warpped some commonly used basic operations so that you can use to build the augmentation
# pipeline. The `internal` column is what you'd probably do outside of `Augmentor`.

# | Category             | internal                | Augmentor          |
# | ---                  | ---                     | ---                |
# | Conversion           | `T.(img)`               | `ConvertEltype(T)` |
# | Information Layout   | `ImageCore.channelview` | `SplitChannels`    |
# | Information Layout   | `ImageCore.colorview`   | `CombineChannels`  |
# | Information Layout   | `Base.permutedims`      | `PermuteDims`      |
# | Information Layout   | `Base.reshape`          | `Reshape`          |

# It is not uncommon that machine learning frameworks require the data in a specific form and layout.
# For example many deep learning frameworks expect the colorchannel of the images to be encoded in
# the third dimension of a 4-dimensional array. Augmentor allows to convert from (and to) these
# different layouts using special operations that are mainly useful in the beginning or end of a
# augmentation pipeline.

using Augmentor
using ImageCore

## 300×400 Matrix{RGB{N0f8}, 2} => 300×400×3 Array{Float32, 3}
img = testpattern(RGB, ratio=0.5)
img_in = augment(img, SplitChannels() |> PermuteDims(2, 3, 1) |> ConvertEltype(Float32))

## 300×400×3 Array{Float32, 3} => 300×400 Matrix{RGB{N0f8}, 2}
img_out = augment(img_in, ConvertEltype(N0f8) |> PermuteDims(3, 1, 2) |> CombineChannels(RGB))

img_out == img


# ## References

#md # ```@docs
#md # ConvertEltype
#md # SplitChannels
#md # CombineChannels
#md # PermuteDims
#md # Reshape
#md # ```

## save covers #src
using ImageMagick #src
include(joinpath("..", "assets", "utilities.jl")) #src
cover = make_gif(testpattern(RGB, ratio=0.5), ConvertEltype(Gray{N0f8}), 2) #src
ImageMagick.save("layout.gif", cover; fps=1) #src
