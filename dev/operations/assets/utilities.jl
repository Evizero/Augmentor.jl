using Augmentor
using ImageCore
using Random
using ImageCore: GenericImage

"""
    make_gif(img, pl, num_sample; random_seed=1337, kwargs...)

Augment `img` with pipeline `pl` for num_sample times, and concatenate them into a 3 dimensional
image.

# Examples

The main purpose of this function is to generate a 3-dimensional image so that we could save a gif
cover using `ImageMagick.save`.

```julia
using Augmentor, ImageMagick
cover = make_gif(testpattern(RGB), FlipX(), 2)
ImageMagick.save("flipx.gif", cover; fps=1)
```

`img` can be a list of images, too. In this case, additional `kwargs` are passed to `mosaicview` so
that you could control how images are ordered.

```julia
pl = ElasticDistortion(6, scale=0.3, border=true) |>
     Rotate([10, -5, -3, 0, 3, 5, 10]) |>
     ShearX(-10:10) * ShearY(-10:10) |>
     CropSize(28, 28) |>
     Zoom(0.9:0.1:1.2)

n_samples, n_frames = 24, 10
imgs = [MNIST.convert2image(MNIST.traintensor(i)) for i in 1:n_samples]
preview = make_gif(imgs, pl, n_frames; nrow=1)
```
"""
function make_gif(img::GenericImage, pl, num_sample; post_op=center_pad ∘ drawborder, random_seed=1337)
    Random.seed!(random_seed)

    fillvalue = oneunit(eltype(img))
    frames = sym_paddedviews(
        fillvalue,
        post_op(img),
        [post_op(augment(img, pl)) for _ in 1:num_sample-1]...
    )
    cat(frames..., dims=3)
end

function make_gif(img, pl, num_sample; post_op=drawborder, random_seed=1337, kwargs...)
    fillvalue = oneunit(eltype(img[1]))

    init_frame = mosaicview(post_op.(img); kwargs...)
    frames = map(1:num_sample-1) do _
        mosaicview(map(x->post_op(augment(x, pl)), img)...; kwargs...)
    end

    frames = sym_paddedviews(fillvalue, init_frame, frames...)
    cat(frames..., dims=3)
end

"""
    center_pad(img, sz=(240, 200))

Pad img with white pixels to height:width ratio `sz[1]:sz[2]`.

Note that `sz` here is not the output size.
"""
function center_pad(img::AbstractMatrix, sz=(240, 200))
    # the default size (240, 200) is used in DemoCards
    fillvalue = oneunit(eltype(img))

    # make sure we don't shrink the image
    h, w = size(img)
    ratio = sz[1]/sz[2]
    pad_sz = h/w > ratio ? (h, round(Int, w / ratio)) : (round(Int, h * ratio), w)
    pad_sz = max.(size(img), pad_sz)

    offset = (pad_sz .- size(img)) .÷ 2
    PaddedView(fillvalue, img, ntuple(i -> -offset[i]:pad_sz[i]-offset[i]+1, ndims(img)))
end

function drawborder(img, fillvalue=colorant"pink")
    img = copy(img)
    img[1, 1:end] .= fillvalue
    img[1:end, 1] .= fillvalue
    img[end, 1:end] .= fillvalue
    img[1:end, end] .= fillvalue
    img
end
