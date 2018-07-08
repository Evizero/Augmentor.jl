_berror() = throw(ArgumentError("Number of output images must be equal to the number of input images"))

imagesvector(imgs::AbstractArray, args...) = obsview(imgs, args...)
imagesvector(imgs::Tuple{Vararg{AbstractArray}}, args...) = obsview(imgs, args...)
@inline imagesvector(imgs::AbstractVector{<:AbstractArray}, args...) = imgs
@inline imagesvector(imgs::AbstractVector{<:Tuple{Vararg{AbstractArray}}}, args...) = imgs

# --------------------------------------------------------------------

"""
    augmentbatch!([resource], outs, imgs, pipeline, [obsdim]) -> outs

Apply the operations of the given `pipeline` to the images in
`imgs` and write the resulting images into `outs`.

Both `outs` and `imgs` have to contain the same number of images.
Each of these two variables can either be in the form of a higher
dimensional array, in the form of a vector of arrays for which
each vector element denotes an image.

```julia
# create five example observations of size 3x3
imgs = rand(3,3,5)
# create output arrays of appropriate shape
outs = similar(imgs)
# transform the batch of images
augmentbatch!(outs, imgs, FlipX() |> FlipY())
```

If one (or both) of the two parameters `outs` and `imgs` is a
higher dimensional array, then the optional parameter `obsdim`
can be used specify which dimension denotes the observations
(defaults to `ObsDim.Last()`),

```julia
# create five example observations of size 3x3
imgs = rand(5,3,3)
# create output arrays of appropriate shape
outs = similar(imgs)
# transform the batch of images
augmentbatch!(outs, imgs, FlipX() |> FlipY(), ObsDim.First())
```

Similar to [`augment!`](@ref), it is also allowed for `outs` and
`imgs` to both be tuples of the same length. If that is the case,
then each tuple element can be in any of the forms listed above.
This is useful for tasks such as image segmentation, where each
observations is made up of more than one image.

```julia
# create five example observations where each observation is
# made up of two conceptually linked 3x3 arrays
imgs = (rand(3,3,5), rand(3,3,5))
# create output arrays of appropriate shape
outs = similar.(imgs)
# transform the batch of images
augmentbatch!(outs, imgs, FlipX() |> FlipY())
```

The parameter `pipeline` can be a `Augmentor.Pipeline`, a tuple
of `Augmentor.Operation`, or a single `Augmentor.Operation`.

```julia
augmentbatch!(outs, imgs, FlipX() |> FlipY())
augmentbatch!(outs, imgs, (FlipX(), FlipY()))
augmentbatch!(outs, imgs, FlipX())
```

The optional first parameter `resource` can either be `CPU1()`
(default) or `CPUThreads()`. In the later case the images will be
augmented in parallel. For this to make sense make sure that the
environment variable `JULIA_NUM_THREADS` is set to a reasonable
number so that `Threads.nthreads()` is greater than 1.

```julia
# transform the batch of images in parallel using multithreading
augmentbatch!(CPUThreads(), outs, imgs, FlipX() |> FlipY())
```
"""
function augmentbatch!(
        outs::Union{Tuple, AbstractArray},
        imgs::Union{Tuple, AbstractArray},
        pipeline,
        args...)
    augmentbatch!(CPU1(), outs, imgs, pipeline, args...)
end

function augmentbatch!(
        r::AbstractResource,
        outs::Union{Tuple, AbstractArray},
        imgs::Union{Tuple, AbstractArray},
        pipeline,
        obsdim = MLDataPattern.default_obsdim(outs))
    augmentbatch!(r, imagesvector(outs, obsdim), imagesvector(imgs, obsdim), pipeline)
    outs
end

function augmentbatch!(
        ::CPU1,
        outs::AbstractVector{<:Union{Tuple, AbstractArray}},
        imgs::AbstractVector{<:Union{Tuple, AbstractArray}},
        pipeline)
    length(outs) == length(imgs) || _berror()
    for i in 1:length(outs)
        augment!(outs[i], imgs[i], pipeline)
    end
    outs
end

function augmentbatch!(
        ::CPUThreads,
        outs::AbstractVector{<:Union{Tuple, AbstractArray}},
        imgs::AbstractVector{<:Union{Tuple, AbstractArray}},
        pipeline)
    length(outs) == length(imgs) || _berror()
    Threads.@threads for i in 1:length(outs)
        augment!(outs[i], imgs[i], pipeline)
    end
    outs
end
