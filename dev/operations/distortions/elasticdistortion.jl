using Augmentor
using ImageShow, ImageCore
using Random

img_in = testpattern(RGB, ratio=0.5)

mosaicview(
    img_in,
    augment(img_in, ElasticDistortion(15,15,0.1)),
    augment(img_in, ElasticDistortion(10,10,0.2,4,3,true));
    fillvalue=colorant"white", nrow=1, npad=10
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

