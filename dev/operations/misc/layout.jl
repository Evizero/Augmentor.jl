using Augmentor
using ImageCore

# 300×400 Matrix{RGB{N0f8}, 2} => 300×400×3 Array{Float32, 3}
img = testpattern(RGB, ratio=0.5)
img_in = augment(img, SplitChannels() |> PermuteDims(2, 3, 1) |> ConvertEltype(Float32))

# 300×400×3 Array{Float32, 3} => 300×400 Matrix{RGB{N0f8}, 2}
img_out = augment(img_in, ConvertEltype(N0f8) |> PermuteDims(3, 1, 2) |> CombineChannels(RGB))

img_out == img

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

