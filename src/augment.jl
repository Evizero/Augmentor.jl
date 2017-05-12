function augment{N}(img, pipeline::Pipeline{N})
    plain_array(_augment(img, pipeline))
end

function augment(img, pipeline::Pipeline{1})
    augment(img, first(pipeline))
end

function augment(img, op::Operation)
    plain_array(applyeager(op, img))
end

function augment(op::Union{Pipeline,Operation})
    augment(use_testpattern(), op)
end

# --------------------------------------------------------------------

@inline function _augment{N}(img, pipeline::Pipeline{N})
    _augment(img, pipeline...)
end

@generated function _augment(img, pipeline::Vararg)
    Expr(:block, Expr(:meta, :inline), build_pipeline(:img, pipeline))
end
