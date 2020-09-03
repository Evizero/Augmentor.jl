# ---
# title: ElasticDistortion
# cover: elasticdistortion.gif
# id: op_elastic
# ---

# Smoothed random distortion

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

# ## Reference

#md # ```@docs
#md # ElasticDistortion
#md # ```

## save covers #src
using ImageMagick #src
include(joinpath("..", "assets", "utilities.jl")) #src
cover = make_gif(testpattern(RGB, ratio=0.5), ElasticDistortion(15,15,0.1), 10) #src
ImageMagick.save("elasticdistortion.gif", cover; fps=2) #src
