@inline _plain_array(A::OffsetArray) = parent(A)
@inline _plain_array(A::Array) = A
@inline plain_array(A::OffsetArray) = parent(A)
@inline plain_array(A::Array) = A
plain_array(A::AbstractArray) = _plain_array(copy(A)) # avoid recursion

# --------------------------------------------------------------------

function indirect_indices(::Tuple{}, ::Tuple{})
    throw(MethodError(indirect_indices, ((),())))
end

@inline function indirect_indices{N}(O::NTuple{N,Base.OneTo}, I::NTuple{N,AbstractUnitRange})
    map(IdentityRange, I)
end

@inline function indirect_indices{N}(O::NTuple{N,Base.OneTo}, I::NTuple{N,StepRange})
    I
end

@inline function indirect_indices{N}(O::NTuple{N,AbstractUnitRange}, I::NTuple{N,AbstractUnitRange})
    map((i1,i2) -> IdentityRange(UnitRange(i1)[i2]), O, I)
end

@inline function indirect_indices{N}(O::NTuple{N,AbstractUnitRange}, I::NTuple{N,StepRange})
    map((i1,i2) -> UnitRange(i1)[i2], O, I)
end

@inline function indirect_indices{N}(O::NTuple{N,StepRange}, I::NTuple{N,Range})
    map((i1,i2) -> i1[i2], O, I)
end

# --------------------------------------------------------------------

@inline function indirect_view(A::AbstractArray, I::Tuple)
    view(A, indirect_indices(indices(A), I)...)
end

@inline function indirect_view(A::SubArray, I::Tuple)
    view(parent(A), indirect_indices(A.indexes, I)...)
end

# --------------------------------------------------------------------

function direct_indices(::Tuple{}, ::Tuple{})
    throw(MethodError(direct_indices, ((),())))
end

function direct_indices{N}(O::NTuple{N,IdentityRange}, I::NTuple{N,StepRange})
    throw(MethodError(direct_indices, (O, I)))
end

@inline function direct_indices{N}(O::NTuple{N,Range}, I::NTuple{N,AbstractUnitRange})
    map(IdentityRange, I)
end

@inline function direct_indices{N}(O::NTuple{N,Range}, I::NTuple{N,StepRange})
    I
end

# --------------------------------------------------------------------

@inline function direct_view{T,N}(A::AbstractArray{T,N}, I::NTuple{N,Range})
    view(A, direct_indices(indices(A), I)...)
end

@inline function direct_view{T,N}(A::SubArray{T,N}, I::NTuple{N,Range})
    view(A, direct_indices(A.indexes, I)...)
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
