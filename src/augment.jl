function augment{T<:ImageTransform}(img, pipeline::AbstractVector{T})
    augment(img, (pipeline...))
end

function augment{N}(img, pipeline::NTuple{N,ImageTransform})
    _toarray(_augment(img, pipeline))
end

function augment(img, tfm::ImageTransform)
    _toarray(applyeager(tfm, img))
end

function augment(img, pipeline::Tuple{ImageTransform})
    _toarray(applyeager(first(pipeline), img))
end

# --------------------------------------------------------------------

@inline function _augment{N}(img, pipeline::NTuple{N,ImageTransform})
    _augment(img, pipeline...)
end

@generated function _augment(img, pipeline::Vararg)
    compile_pipeline(:img, pipeline)
end
