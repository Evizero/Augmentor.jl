_berror() = throw(ArgumentError("Number of output images must be equal to the number of input images"))

imagesvector(imgs::AbstractArray) = obsview(imgs)
@inline imagesvector(imgs::AbstractVector{<:AbstractArray}) = imgs

# --------------------------------------------------------------------

"""
    augmentbatch!([resource], outs, imgs, pipeline) -> outs

Apply the operations of the given `pipeline` to the images in
`imgs` and write the resulting images into `outs`.

Both `outs` and `imgs` have to contain the same number of images.
Each of the two variables can either be in the form of a higher
dimensional array for which the last dimension enumerates the
individual images, or alternatively in the form of a vector of
arrays, for which each vector element denotes an image.

The parameter `pipeline` can be a subtype of
`Augmentor.Pipeline`, a tuple of `Augmentor.Operation`, or a
single `Augmentor.Operation`.

The optional first parameter `resource` can either be `CPU1()`
(default) or `CPUThreads()`. In the case of the later the images
will be augmented in parallel. For this to make sense make sure
that the environment variable `JULIA_NUM_THREADS` is set to a
reasonable number so that `Threads.nthreads()` is greater than 1.
"""
function augmentbatch!(
        outs::AbstractArray,
        imgs::AbstractArray,
        pipeline)
    augmentbatch!(CPU1(), outs, imgs, pipeline)
end

function augmentbatch!(
        r::AbstractResource,
        outs::AbstractArray,
        imgs::AbstractArray,
        pipeline)
    augmentbatch!(r, imagesvector(outs), imagesvector(imgs), pipeline)
    outs
end

function augmentbatch!(
        ::CPU1,
        outs::AbstractVector{<:AbstractArray},
        imgs::AbstractVector{<:AbstractArray},
        pipeline)
    length(outs) == length(imgs) || _berror()
    for i in 1:length(outs)
        augment!(outs[i], imgs[i], pipeline)
    end
    outs
end

function augmentbatch!(
        ::CPUThreads,
        outs::AbstractVector{<:AbstractArray},
        imgs::AbstractVector{<:AbstractArray},
        pipeline)
    length(outs) == length(imgs) || _berror()
    Threads.@threads for i in 1:length(outs)
        augment!(outs[i], imgs[i], pipeline)
    end
    outs
end
