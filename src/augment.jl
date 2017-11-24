"""
    augment([img], pipeline) -> imga

Apply the operations of the given `pipeline` to the image `img`
and return the resulting image `imga`.

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

Apply the operations of the given `pipeline` to the image `img`
and write the resulting image into `out`.

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
