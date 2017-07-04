"""
    augment([img], pipeline) -> imga

Apply the operations of the given `pipeline` to the image `img`
and return the resulting image `imga`.

The parameter `pipeline` can be a subtype of
`Augmentor.Pipeline`, a tuple of `Augmentor.Operation`, or a
single `Augmentor.Operation`

```julia
img = testpattern()
augment(img, FlipX() |> FlipY())
augment(img, (FlipX(), FlipY()))
augment(img, FlipX())
```

If `img` is omitted, augmentor will use the pre-provided
augmentation test image returned by the function
[`testpattern`](@ref) as the input image.

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

function augment!(out, img, pipeline::AbstractPipeline)
    out_lazy = _augment_avoid_eager(img, pipeline)
    copy!(match_idx(out, indices(out_lazy)), out_lazy)
    out
end

@inline function _augment_avoid_eager(img, pipeline::AbstractPipeline)
    _augment_avoid_eager(img, operations(pipeline)...)
end

@generated function _augment_avoid_eager(img, pipeline::Vararg{Operation})
    Expr(:block, Expr(:meta, :inline), augment_impl(:img, pipeline, true))
end

