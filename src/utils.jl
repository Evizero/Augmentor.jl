@inline plain_array(A::OffsetArray) = parent(A)
@inline plain_array(A::Array) = A
plain_array(A::AbstractArray) = plain_array(copy(A))

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

function identity_view{T,N,P}(A::SubArray{T,N,P,NTuple{N,IdentityRange{Int}}}, I::NTuple{N,AbstractUnitRange})
    idx = map((i1,i2) -> UnitRange(i1)[i2], A.indexes, I)
    view(parent(A), map(IdentityRange, idx)...)
end

function identity_view{T,N,P}(A::SubArray{T,N,P,NTuple{N,IdentityRange{Int}}}, I::NTuple{N,StepRange})
    idx = map((i1,i2) -> UnitRange(i1)[i2], A.indexes, I)
    view(parent(A), idx...)
end

