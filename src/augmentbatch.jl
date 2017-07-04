_berror() = throw(ArgumentError("Number of output images must be equal to the number of input images"))

imagesvector(imgs::AbstractArray) = obsview(imgs)
@inline imagesvector(imgs::AbstractVector{<:AbstractArray}) = imgs

# --------------------------------------------------------------------

function augmentbatch!(
        outs::AbstractArray,
        imgs::AbstractArray,
        pipeline::AbstractPipeline)
    augmentbatch!(CPU1(), outs, imgs, pipeline)
end

function augmentbatch!(
        r::AbstractResource,
        outs::AbstractArray,
        imgs::AbstractArray,
        pipeline::AbstractPipeline)
    augmentbatch!(r, imagesvector(outs), imagesvector(imgs), pipeline)
    outs
end

function augmentbatch!(
        ::CPU1,
        outs::AbstractVector{<:AbstractArray},
        imgs::AbstractVector{<:AbstractArray},
        pipeline::AbstractPipeline)
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
        pipeline::AbstractPipeline)
    length(outs) == length(imgs) || _berror()
    Threads.@threads for i in 1:length(outs)
        augment!(outs[i], imgs[i], pipeline)
    end
    outs
end
