"""
    testpattern() -> Matrix{RGBA{N0f8}}

Load and return the provided 300x400 test image.

The returned image was specifically designed to be informative
about the effects of the applied augmentation operations. It is
thus well suited to prototype an augmentation pipeline, because it
makes it easy to see what kind of effects one can achieve with it.
"""
testpattern() = load(joinpath(dirname(@__FILE__()), "..", "resources", "testpattern.png"))

function use_testpattern()
    info("No custom image specifed. Using \"testpattern()\" for demonstration.")
    testpattern()
end

# --------------------------------------------------------------------

@inline _plain_array(A::OffsetArray) = parent(A)
@inline _plain_array(A::Array) = A
@inline plain_array(A::OffsetArray) = parent(A)
@inline plain_array(A::Array) = A
# avoid recursion
@inline plain_array(A::SubArray) = _plain_array(copy(A))
@inline plain_array(A::AbstractArray) = _plain_array(collect(A))

# --------------------------------------------------------------------

@inline match_idx(buffer::AbstractArray, inds::Tuple) = buffer
@inline match_idx(buffer::Union{Array,SubArray}, inds::NTuple{N,UnitRange}) where {N} =
    OffsetArray(buffer, inds)

# --------------------------------------------------------------------

function indirect_indices(::Tuple{}, ::Tuple{})
    throw(MethodError(indirect_indices, ((),())))
end

@inline function indirect_indices(O::NTuple{N,Base.OneTo}, I::NTuple{N,AbstractUnitRange}) where N
    map(IdentityRange, I)
end

@inline function indirect_indices(O::NTuple{N,Base.OneTo}, I::NTuple{N,StepRange}) where N
    I
end

function indirect_indices(O::NTuple{N,AbstractUnitRange}, I::NTuple{N,AbstractUnitRange}) where N
    map((i1,i2) -> IdentityRange(UnitRange(i1)[i2]), O, I)
end

function indirect_indices(O::NTuple{N,AbstractUnitRange}, I::NTuple{N,StepRange}) where N
    map((i1,i2) -> UnitRange(i1)[i2], O, I)
end

function indirect_indices(O::NTuple{N,StepRange}, I::NTuple{N,Range}) where N
    map((i1,i2) -> i1[i2], O, I)
end

# --------------------------------------------------------------------

function indirect_view(A::AbstractArray, I::Tuple)
    view(A, indirect_indices(indices(A), I)...)
end

function indirect_view(A::SubArray, I::Tuple)
    view(parent(A), indirect_indices(A.indexes, I)...)
end

# --------------------------------------------------------------------

function direct_indices(::Tuple{}, ::Tuple{})
    throw(MethodError(direct_indices, ((),())))
end

function direct_indices(O::NTuple{N,IdentityRange}, I::NTuple{N,StepRange}) where N
    throw(MethodError(direct_indices, (O, I)))
end

@inline function direct_indices(O::NTuple{N,Range}, I::NTuple{N,AbstractUnitRange}) where N
    map(IdentityRange, I)
end

@inline function direct_indices(O::NTuple{N,Range}, I::NTuple{N,StepRange}) where N
    I
end

# --------------------------------------------------------------------

function direct_view(A::AbstractArray{T,N}, I::NTuple{N,Range}) where {T,N}
    view(A, direct_indices(indices(A), I)...)
end

function direct_view(A::SubArray{T,N}, I::NTuple{N,Range}) where {T,N}
    view(A, direct_indices(A.indexes, I)...)
end

# --------------------------------------------------------------------

@inline _vectorize(A::AbstractVector) = A
@inline _vectorize(A::Real) = A:A

@inline _round(num::Integer, d) = num
_round(num::AbstractFloat, d) = round(num,d)
_round(nums::Tuple, d) = map(num->_round(num,d), nums)

function unionrange(i1::AbstractUnitRange, i2::AbstractUnitRange)
    map(min, first(i1), first(i2)):map(max, last(i1), last(i2))
end

# --------------------------------------------------------------------

function _2dborder!(A::AbstractArray{T,3}, val::T) where T
    ndims, h, w = size(A)
    @inbounds for i = 1:h, j = (1,w)
        for d = 1:ndims
            A[d,i,j] = val
        end
    end
    @inbounds for i = (1,h), j = 1:w
        for d = 1:ndims
            A[d,i,j] = val
        end
    end
    A
end
