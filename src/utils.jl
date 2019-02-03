"""
    testpattern() -> Matrix{RGBA{N0f8}}

Load and return the provided 300x400 test image.

The returned image was specifically designed to be informative
about the effects of the applied augmentation operations. It is
thus well suited to prototype an augmentation pipeline, because it
makes it easy to see what kind of effects one can achieve with it.
"""
testpattern() = load(joinpath(@__DIR__, "..", "resources", "testpattern.png"))

function use_testpattern()
    @info("No custom image specifed. Using \"testpattern()\" for demonstration.")
    testpattern()
end

# --------------------------------------------------------------------
# rand() is not threadsafe (https://discourse.julialang.org/t/4683)

# Because we only require random numbers to sample parameters
# and not the actual expensive computation, this seems like a better
# approach than using separate RNG per thread.
const rand_mutex = Ref{Threads.Mutex}()

# constant overhead of about 80 ns compared to unsafe rand
function safe_rand(args...)
    lock(rand_mutex[])
    result = rand(args...)
    unlock(rand_mutex[])
    result
end

# --------------------------------------------------------------------

@inline maybe_copy(A::OffsetArray) = A
@inline maybe_copy(A::Array) = A
@inline maybe_copy(A::SArray) = A
@inline maybe_copy(A::MArray) = A
@inline maybe_copy(A::AbstractArray) = match_idx(collect(A), axes(A))
@inline maybe_copy(A::Tuple) = map(maybe_copy, A)

# --------------------------------------------------------------------

@inline _plain_array(A::OffsetArray) = parent(A)
@inline _plain_array(A::Array) = A
@inline _plain_array(A::SArray) = A
@inline _plain_array(A::MArray) = A
@inline _plain_array(A::Tuple) = map(_plain_array, A)
# avoid recursion
@inline plain_array(A) = _plain_array(maybe_copy(A))

# --------------------------------------------------------------------

@inline plain_axes(A::Array) = A
@inline plain_axes(A::OffsetArray) = parent(A)
@inline plain_axes(A::AbstractArray) = _plain_axes(A, axes(A))
@inline plain_axes(A::SubArray) = _plain_axes(A, A.indices)

@inline function _plain_axes(A::AbstractArray{T,N}, ids::NTuple{N,Base.OneTo}) where {T, N}
    A
end

@inline function _plain_axes(A::AbstractArray, ids::Tuple{Vararg{Any}})
    view(A, axes(A)...)
end

@inline function _plain_axes(A::AbstractArray{T,N}, ids::NTuple{N,Base.Slice}) where {T, N}
    view(A, map(i->i.indices, ids)...)
end

@inline function _plain_axes(A::SubArray{T,N}, ids::NTuple{N,IdentityRange}) where {T, N}
    view(parent(A), axes(A)...)
end

# --------------------------------------------------------------------

@inline match_idx(buffer::AbstractArray, inds::Tuple) = buffer
@inline match_idx(buffer::Union{Array,SubArray}, inds::NTuple{N,Union{UnitRange,Base.Slice{<:UnitRange}}}) where {N} =
    OffsetArray(buffer, inds)

# --------------------------------------------------------------------

function indirect_axes(::Tuple{}, ::Tuple{})
    throw(MethodError(indirect_axes, ((),())))
end

@inline function indirect_axes(O::NTuple{N,Base.OneTo}, I::NTuple{N,AbstractUnitRange}) where N
    map(IdentityRange, I)
end

@inline function indirect_axes(O::NTuple{N,Base.OneTo}, I::NTuple{N,StepRange}) where N
    I
end

function indirect_axes(O::NTuple{N,AbstractUnitRange}, I::NTuple{N,AbstractUnitRange}) where N
    map((i1,i2) -> IdentityRange(UnitRange(i1)[i2]), O, I)
end

function indirect_axes(O::NTuple{N,AbstractUnitRange}, I::NTuple{N,StepRange}) where N
    map((i1,i2) -> UnitRange(i1)[i2], O, I)
end

function indirect_axes(O::NTuple{N,StepRange}, I::NTuple{N,AbstractRange}) where N
    map((i1,i2) -> i1[i2], O, I)
end

# --------------------------------------------------------------------

function indirect_view(A::AbstractArray, I::Tuple)
    view(A, indirect_axes(axes(A), I)...)
end

function indirect_view(A::SubArray{T,N,TA,<:NTuple{N,AbstractRange}}, I::Tuple) where {T,N,TA}
    view(parent(A), indirect_axes(A.indices, I)...)
end

# --------------------------------------------------------------------

function direct_axes(::Tuple{}, ::Tuple{})
    throw(MethodError(direct_axes, ((),())))
end

# TODO: Figure out why this method exists
function direct_axes(O::NTuple{N,IdentityRange}, I::NTuple{N,StepRange}) where N
    throw(MethodError(direct_axes, (O, I)))
end

@inline function direct_axes(O::NTuple{N,AbstractRange}, I::NTuple{N,AbstractUnitRange}) where N
    map(IdentityRange, I)
end

@inline function direct_axes(O::NTuple{N,AbstractRange}, I::NTuple{N,StepRange}) where N
    I
end

# --------------------------------------------------------------------

function direct_view(A::AbstractArray{T,N}, I::NTuple{N,AbstractRange}) where {T,N}
    view(A, direct_axes(axes(A), I)...)
end

function direct_view(A::SubArray{T,N,TA,<:NTuple{N,AbstractRange}}, I::NTuple{N,AbstractRange}) where {T,N,TA}
    view(A, direct_axes(A.indices, I)...)
end

# --------------------------------------------------------------------

@inline vectorize(A::AbstractVector) = A
@inline vectorize(A::Real) = A:A

@inline round_if_float(num::Integer, d) = num
round_if_float(num::AbstractFloat, d) = round(num, digits=d)
round_if_float(nums::Tuple, d) = map(num->round_if_float(num,d), nums)

function unionrange(i1::AbstractUnitRange, i2::AbstractUnitRange)
    map(min, first(i1), first(i2)):map(max, last(i1), last(i2))
end

@inline _showcolor(io::IO, T::Type{<:Number}) = print(io, T)
@inline _showcolor(io::IO, T) = ColorTypes.colorant_string_with_eltype(io, T)

# --------------------------------------------------------------------

function _2dborder!(A::AbstractArray{T,3}, val::T) where T
    ndims, h, w = size(A)
    @inbounds for j = (1,w), i = 1:h
        for d = 1:ndims
            A[d,i,j] = val
        end
    end
    @inbounds for j = 1:w, i = (1,h)
        for d = 1:ndims
            A[d,i,j] = val
        end
    end
    A
end

#import ImageTransformations: restrict_indices

# ImageTransformations.restrict_indices(r::Base.IdentityUnitRange) =
#     restrict_indices(r.indices)
