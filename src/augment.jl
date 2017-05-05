function augment{N}(img, pipeline::NTuple{N,ImageTransform})
    plain_array(_augment(img, pipeline))
end

function augment(img, tfm::ImageTransform)
    plain_array(applyeager(tfm, img))
end

function augment(img, pipeline::Tuple{ImageTransform})
    plain_array(applyeager(first(pipeline), img))
end

# --------------------------------------------------------------------

@inline function _augment{N}(img, pipeline::NTuple{N,ImageTransform})
    _augment(img, pipeline...)
end

@generated function _augment(img, pipeline::Vararg)
    compile_pipeline(:img, pipeline)
end
