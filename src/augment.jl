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

# --------------------------------------------------------------------

@inline function _augment(img, pipeline::AbstractPipeline)
    _augment(img, operations(pipeline)...)
end

@generated function _augment(img, pipeline::Vararg{Operation})
    Expr(:block, Expr(:meta, :inline), build_pipeline(:img, pipeline))
end
