"""
    CacheImage <: Augmentor.ImageOperation

Description
--------------

Write the current state of the image into the working memory.
Optionally a user has the option to specify a preallocated
`buffer` to write the image into. Note that if a `buffer` is
provided, then it has to be of the correct size and eltype.

Even without a preallocated `buffer` it can be beneficial in some
situations to cache the image. An example for such a scenario is
when chaining a number of affine transformations after an elastic
distortion, because performing that lazily requires nested
interpolation.

Usage
--------------

    CacheImage()

    CacheImage(buffer)

Arguments
--------------

- **`buffer`** : Optional. A preallocated `AbstractArray` of the
    appropriate size and eltype.

Examples
--------------

```julia
using Augmentor

# make pipeline that forces caching after elastic distortion
pl = ElasticDistortion(3,3) |> CacheImage() |> Rotate(-10:10) |> ShearX(-5:5)

# cache output of elastic distortion into the allocated
# 20x20 Matrix{Float64}. Note that for this case this assumes that
# the input image is also a 20x20 Matrix{Float64}
pl = ElasticDistortion(3,3) |> CacheImage(zeros(20,20)) |> Rotate(-10:10)

# convenience syntax with the same effect as above.
pl = ElasticDistortion(3,3) |> zeros(20,20) |> Rotate(-10:10)
```

see also
--------------

[`augment`](@ref)
"""
struct CacheImage <: ImageOperation end

applyeager(op::CacheImage, img::Array) = img
applyeager(op::CacheImage, img::OffsetArray) = img
applyeager(op::CacheImage, img::SubArray) = copy(img)
applyeager(op::CacheImage, img::InvWarpedView) = copy(img)
applyeager(op::CacheImage, img) = collect(img)

function showconstruction(io::IO, op::CacheImage)
    print(io, typeof(op).name.name, "()")
end

function Base.show(io::IO, op::CacheImage)
    if get(io, :compact, false)
        print(io, "Cache into temporary buffer")
    else
        print(io, "Augmentor.")
        showconstruction(io, op)
    end
end

# --------------------------------------------------------------------

"""
    CacheImageInto <: Augmentor.ImageOperation

see [`CacheImage`](@ref)
"""
struct CacheImageInto{T<:AbstractArray} <: ImageOperation
    buffer::T
end
CacheImage(buffer::AbstractArray) = CacheImageInto(buffer)

@inline supports_lazy(::Type{<:CacheImageInto}) = true

@inline match_idx(buffer::AbstractArray, inds::Tuple) = buffer
@inline match_idx(buffer::Array, inds::NTuple{N,UnitRange}) where {N} =
    OffsetArray(buffer, inds)

applyeager(op::CacheImageInto, img) = applylazy(op, img)

function applylazy(op::CacheImageInto, img)
    copy!(match_idx(op.buffer, indices(img)), img)
end

function showconstruction(io::IO, op::CacheImageInto)
    print(io, "CacheImage(") # shows exported API
    print(io, "Array{")
    ImageCore.showcoloranttype(io, eltype(op.buffer))
    print(io, "}(")
    print(io, join(map(i->string(length(i)), indices(op.buffer)), ", "))
    print(io, "))")
end

function Base.show(io::IO, op::CacheImageInto)
    if get(io, :compact, false)
        print(io, "Cache into preallocated ", summary(op.buffer))
    else
        print(io, typeof(op).name, "(")
        showarg(io, op.buffer)
        print(io, ')')
    end
end
