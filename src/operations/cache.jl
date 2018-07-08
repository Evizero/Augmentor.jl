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

See also
--------------

[`augment`](@ref)

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
"""
struct CacheImage <: ImageOperation end

applyeager(op::CacheImage, img::AbstractArray, param) = maybe_copy(img)

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
struct CacheImageInto{T<:Union{AbstractArray,Tuple}} <: ImageOperation
    buffer::T
end
CacheImage(buffer::AbstractArray) = CacheImageInto(buffer)
CacheImage(buffers::AbstractArray...) = CacheImageInto(buffers)
CacheImage(buffers::NTuple{N,AbstractArray}) where {N} = CacheImageInto(buffers)

@inline supports_lazy(::Type{<:CacheImageInto}) = true

applyeager(op::CacheImageInto, img::AbstractArray, param) = applylazy(op, img)
applyeager(op::CacheImageInto, img::Tuple) = applylazy(op, img)

function applylazy(op::CacheImageInto, img::Tuple)
    throw(ArgumentError("Operation $(op) not compatiable with given image(s) ($(summary(img))). This can happen if the amount of images does not match the amount of buffers in the operation"))
end

function applylazy(op::CacheImageInto{<:AbstractArray}, img::AbstractArray, param)
    copy!(match_idx(op.buffer, indices(img)), img)
end

function applylazy(op::CacheImageInto{<:Tuple}, imgs::Tuple)
    map(op.buffer, imgs) do buffer, img
        copy!(match_idx(buffer, indices(img)), img)
    end
end

function _showconstruction(io::IO, array::AbstractArray)
    print(io, "Array{")
    _showcolor(io, eltype(array))
    print(io, "}(")
    print(io, join(map(i->string(length(i)), indices(array)), ", "))
    print(io, ")")
end

function showconstruction(io::IO, op::CacheImageInto{<:AbstractArray})
    print(io, "CacheImage(") # shows exported API
    _showconstruction(io, op.buffer)
    print(io, ")")
end

function showconstruction(io::IO, op::CacheImageInto{<:Tuple})
    print(io, "CacheImage(")
    for (i, buffer) in enumerate(op.buffer)
        _showconstruction(io, buffer)
        i < length(op.buffer) && print(io, ", ")
    end
    print(io, ")")
end

function Base.show(io::IO, op::CacheImageInto{<:AbstractArray})
    if get(io, :compact, false)
        print(io, "Cache into preallocated ")
        print(io, summary(op.buffer))
    else
        print(io, typeof(op).name, "(")
        showarg(io, op.buffer)
        print(io, ")")
    end
end

function Base.show(io::IO, op::CacheImageInto{<:Tuple})
    if get(io, :compact, false)
        print(io, "Cache into preallocated ")
        print(io, "(", join(map(summary, op.buffer), ", "), ")")
    else
        print(io, typeof(op).name, "((")
        for (i, buffer) in enumerate(op.buffer)
            showarg(io, buffer)
            i < length(op.buffer) && print(io, ", ")
        end
        print(io, "))")
    end
end
