"""
    augment([img], pipeline) -> out

Apply the operations of the given `pipeline` sequentially to the
given image `img` and return the resulting image `out`.

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
"""
function augment(img, pipeline::AbstractPipeline)
    plain_array(_augment(img, pipeline))
end

function augment(img, pipeline::Union{ImmutablePipeline{1},NTuple{1,Operation}})
    augment(img, first(operations(pipeline)))
end

function augment(img, op::Operation)
    plain_array(applyeager(op, img))
end

function augment(op::Union{AbstractPipeline,Operation})
    augment(use_testpattern(), op)
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
    copy!(match_idx(out, indices(out_lazy)), out_lazy)
    out
end

function augment!(outs::NTuple{N,AbstractArray}, imgs::NTuple{N,AbstractArray}, pipeline::AbstractPipeline) where N
    outs_lazy = _augment_avoid_eager(imgs, pipeline)
    map(outs, outs_lazy) do out, out_lazy
        copy!(match_idx(out, indices(out_lazy)), out_lazy)
    end
    outs
end

@inline function _augment_avoid_eager(img, pipeline::AbstractPipeline)
    _augment_avoid_eager(img, operations(pipeline)...)
end

@generated function _augment_avoid_eager(img, pipeline::Vararg{Operation})
    Expr(:block, Expr(:meta, :inline), augment_impl(:img, pipeline, true))
end
