immutable CacheImage <: Operation end

applyeager(op::CacheImage, img) = plain_array(img)

function Base.show(io::IO, op::CacheImage)
    if get(io, :compact, false)
        print(io, "Cache into temporary buffer")
    else
        print(io, "$(typeof(op))()")
    end
end

# --------------------------------------------------------------------

immutable CacheImage!{T<:AbstractArray} <: Operation
    buffer::T
end

@inline _offset{N}(buffer::OffsetArray, inds::NTuple{N,UnitRange}) = buffer
@inline _offset(buffer::AbstractArray, inds::Tuple) = buffer
@inline _offset{N}(buffer::Array, inds::NTuple{N,UnitRange}) =
    OffsetArray(buffer, inds)

function applyeager(op::CacheImage!, img)
    copy!(_offset(op.buffer, indices(img)), img)
end

function Base.show(io::IO, op::CacheImage!)
    if get(io, :compact, false)
        print(io, "Cache into preallocated ", summary(op.buffer))
    else
        print(io, "$(typeof(op).name)(")
        showarg(io, op.buffer)
        print(io, ')')
    end
end
