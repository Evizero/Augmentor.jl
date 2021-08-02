"""
    augment([img], pipeline) -> out
    augment(img=>mask, pipeline) -> out

Apply the operations of the given `pipeline` sequentially to the
given image `img` and return the resulting image `out`. For the
second method, see Semantic wrappers below.

```julia-repl
julia> img = testpattern();

julia> out = augment(img, FlipX() |> FlipY())
3×2 Array{Gray{N0f8},2}:
[...]
```

The parameter `img` can either be a single image, or a tuple of
multiple images. In case `img` is a tuple of images, its elements
will be assumed to be conceptually connected. Consequently, all
images in the tuple will take the exact same path through the
pipeline; even when randomness is involved. This is useful for the
purpose of image segmentation, for which the input and output are
both images that need to be transformed exactly the same way.

```julia
img1 = testpattern()
img2 = Gray.(testpattern())
out1, out2 = augment((img1, img2), FlipX() |> FlipY())
```

The parameter `pipeline` can be a `Augmentor.Pipeline`, a tuple
of `Augmentor.Operation`, or a single `Augmentor.Operation`.

```julia
img = testpattern()
augment(img, FlipX() |> FlipY())
augment(img, (FlipX(), FlipY()))
augment(img, FlipX())
```

If `img` is omitted, Augmentor will use the augmentation test
image provided by the function [`testpattern`](@ref) as the input
image.

```julia
augment(FlipX())
```

## Semantic wrappers

It is possible to define more flexible augmentation pipelines by wrapping the
input into a semantic wrapper. Semantic wrappers determine meaning of an input,
and ensure that only appropriate operations are applied on that input.

Currently implemented semantic wrappers are:

- [`Augmentor.Mask`](@ref): Wraps a segmentation mask. Allows only spatial
  transformations.

  The convenient usage for this is `augment(img => mask, pipeline)`.

### Example

```jldoctest
using Augmentor: unwrap, Mask

img, mask = testpattern(), testpattern()
pl = Rotate90() |> GaussianBlur(3)

aug_img, aug_mask = unwrap.(augment((img, Mask(mask)), pl))
# Equivalent usage
aug_img, aug_mask = augment(img => mask, pl)

# GaussianBlur will be skipped for our `mask`
aug_mask == augment(mask, Rotate90())

# output

true
```
"""
augment(img, pipeline) = _plain_augment(img, pipeline)
# convenient interpretation for certain use cases
function augment((img, mask)::Pair{<:AbstractArray, <:AbstractArray}, pipeline)
    img_out, mask_out = augment((img, Mask(mask)), pipeline)
    return img_out => unwrap(mask_out)
end
augment(pipeline) = augment(use_testpattern(), pipeline) # TODO: deprecate this?

# plain augment that faithfully operates on the objects without convenient interpretation
function _plain_augment(img, pipeline::AbstractPipeline)
    plain_array(_augment(img, pipeline))
end

function _plain_augment(img, pipeline::Union{ImmutablePipeline{1},NTuple{1,Operation}})
    augment(img, first(operations(pipeline)))
end

function _plain_augment(img, op::Operation)
    plain_array(applyeager(op, img))
end


@inline function _augment(img, pipeline::AbstractPipeline)
    _augment(img, operations(pipeline)...)
end

@generated function _augment(img, pipeline::Vararg{Operation})
    Expr(:block, Expr(:meta, :inline), augment_impl(:img, pipeline, false))
end

# --------------------------------------------------------------------

"""
    augment!(out, img, pipeline) -> out

Apply the operations of the given `pipeline` sequentially to the
image `img` and write the resulting image into the preallocated
parameter `out`. For convenience `out` is also the function's
return-value.

```julia
img = testpattern()
out = similar(img)
augment!(out, img, FlipX() |> FlipY())
```

The parameter `img` can either be a single image, or a tuple of
multiple images. In case `img` is a tuple of images, the
parameter `out` has to be a tuple of the same length and
ordering. See [`augment`](@ref) for more information.

```julia
imgs = (testpattern(), Gray.(testpattern()))
outs = (similar(imgs[1]), similar(imgs[2]))
augment!(outs, imgs, FlipX() |> FlipY())
```

The parameter `pipeline` can be a `Augmentor.Pipeline`, a tuple
of `Augmentor.Operation`, or a single `Augmentor.Operation`.

```julia
img = testpattern()
out = similar(img)
augment!(out, img, FlipX() |> FlipY())
augment!(out, img, (FlipX(), FlipY()))
augment!(out, img, FlipX())
```
"""
augment!(out, img, op::Operation) = augment!(out, img, (op,))

function augment!(out::AbstractArray, img::AbstractArray, pipeline::AbstractPipeline)
    out_lazy = _augment_avoid_eager(img, pipeline)
    copyto!(match_idx(out, axes(out_lazy)), out_lazy)
    out
end

function augment!(outs::NTuple{N,AbstractArray}, imgs::NTuple{N,AbstractArray}, pipeline::AbstractPipeline) where N
    outs_lazy = _augment_avoid_eager(imgs, pipeline)
    map(outs, outs_lazy) do out, out_lazy
        copyto!(match_idx(out, axes(out_lazy)), out_lazy)
    end
    outs
end

@inline function _augment_avoid_eager(img, pipeline::AbstractPipeline)
    _augment_avoid_eager(img, operations(pipeline)...)
end

@generated function _augment_avoid_eager(img, pipeline::Vararg{Operation})
    Expr(:block, Expr(:meta, :inline), augment_impl(:img, pipeline, true))
end
