immutable Crop{N,I<:Tuple} <: Operation
    indexes::I

    function (::Type{Crop{N}}){N}(indexes::NTuple{N,AbstractUnitRange})
        new{N,typeof(indexes)}(indexes)
    end
end
Crop(::Tuple{}) = throw(MethodError(Crop, ()))
Crop{N}(indexes::NTuple{N,AbstractUnitRange}) = Crop{N}(indexes)
Crop{N}(indexes::Vararg{AbstractUnitRange,N}) = Crop(indexes)
Crop(x, y, width, height) = Crop(y:y+height-1, x:x+width-1)

Base.@pure supports_affine{T<:Crop}(::Type{T}) = true
Base.@pure supports_stepview{T<:Crop}(::Type{T}) = true

applyeager(op::Crop, img) = plain_array(img[op.indexes...])
applyaffine(op::Crop, img) = view(img, map(IdentityRange, op.indexes)...)
applylazy(op::Crop, img) = view(img, op.indexes...)

function applystepview(op::Crop, img::AbstractArray)
    indexes = map(StepRange, op.indexes)
    view(img, indexes...)
end

function Base.show{N}(io::IO, op::Crop{N})
    if get(io, :compact, false)
        print(io, "Crop region $(op.indexes)")
    else
        print(io, "Augmentor.Crop{$N}($(op.indexes))")
    end
end
