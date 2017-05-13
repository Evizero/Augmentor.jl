@inline _plain_array(A::OffsetArray) = parent(A)
@inline _plain_array(A::Array) = A
@inline plain_array(A::OffsetArray) = parent(A)
@inline plain_array(A::Array) = A
plain_array(A::AbstractArray) = _plain_array(copy(A)) # avoid recursion

# --------------------------------------------------------------------
# AVOID AMBIGUOUS METHODS WITH TUPLES ON 0.5 AND 0.6

function identity_view{T}(A::AbstractArray{T,0}, I::Tuple{})
    throw(MethodError(identity_view, ((),)))
end

function identity_view{T,N}(A::AbstractArray{T,N}, I::Tuple{})
    throw(MethodError(identity_view, ((),)))
end

function identity_view{T,P}(A::SubArray{T,0,P,NTuple{0,IdentityRange{Int}}}, I::Tuple{})
    throw(MethodError(identity_view, ((),)))
end

function identity_view{T,N,P}(A::SubArray{T,N,P,NTuple{N,IdentityRange{Int}}}, I::Tuple{})
    throw(MethodError(identity_view, ((),)))
end

# --------------------------------------------------------------------

@inline function identity_view{T,N}(A::AbstractArray{T,N}, I::NTuple{N,AbstractUnitRange})
    view(A, map(IdentityRange, I)...)
end

@inline function identity_view{T,N}(A::AbstractArray{T,N}, I::NTuple{N,StepRange})
    view(A, I...)
end

@inline function identity_view{T,N}(A::AbstractArray{T,N}, I::NTuple{N,IdentityRange})
    view(A, I...)
end

@inline function identity_view{T,N,P}(A::SubArray{T,N,P,NTuple{N,IdentityRange{Int}}}, I::NTuple{N,IdentityRange})
    view(A, I...)
end

function identity_view{T,N,P}(A::SubArray{T,N,P,NTuple{N,IdentityRange{Int}}}, I::NTuple{N,AbstractUnitRange})
    idx = map((i1,i2) -> UnitRange(i1)[i2], A.indexes, I)
    identity_view(parent(A), map(IdentityRange, idx))
end

function identity_view{T,N,P}(A::SubArray{T,N,P,NTuple{N,IdentityRange{Int}}}, I::NTuple{N,StepRange})
    idx = map((i1,i2) -> UnitRange(i1)[i2], A.indexes, I)
    identity_view(parent(A), idx)
end

# --------------------------------------------------------------------

_vectorize(A::AbstractVector) = A
_vectorize(A::Real) = A:A

_round(num::Integer, d) = num
_round(num::AbstractFloat, d) = round(num,d)
_round(nums::Tuple, d) = map(num->_round(num,d), nums)

function unionrange(i1::AbstractUnitRange, i2::AbstractUnitRange)
    map(min, first(i1), first(i2)):map(max, last(i1), last(i2))
end
