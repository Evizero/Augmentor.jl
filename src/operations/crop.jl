immutable Crop{N,I<:Tuple} <: Operation
    indexes::I

    function (::Type{Crop{N}}){N}(indexes::NTuple{N,UnitRange})
        new{N,typeof(indexes)}(indexes)
    end
end
Crop(::Tuple{}) = throw(MethodError(Crop, ()))
Crop{N}(indexes::NTuple{N,UnitRange}) = Crop{N}(indexes)
Crop{N}(indexes::Vararg{UnitRange,N}) = Crop(indexes)
Crop(x, y, width, height) = Crop(y:y+height-1, x:x+width-1)

Base.@pure supports_affine{T<:Crop}(::Type{T}) = true
Base.@pure supports_view{T<:Crop}(::Type{T}) = true
Base.@pure supports_stepview{T<:Crop}(::Type{T}) = true

applyeager(op::Crop, img) = plain_array(img[op.indexes...])
function applyeager{T,N,P}(op::Crop, img::SubArray{T,N,P,NTuple{N,IdentityRange{Int}}})
    plain_array(identity_view(img, op.indexes))
end

applyaffine(op::Crop, img) = identity_view(img, op.indexes)
applylazy(op::Crop, img) = identity_view(img, op.indexes)
applyview(op::Crop, img) = identity_view(img, op.indexes)
applystepview(op::Crop, img) = identity_view(img, map(StepRange, op.indexes))

function Base.show{N}(io::IO, op::Crop{N})
    if get(io, :compact, false)
        print(io, "Crop region $(op.indexes)")
    else
        print(io, "Augmentor.Crop{$N}($(op.indexes))")
    end
end
