immutable Crop{I<:Tuple} <: Operation
    indexes::I

    function (::Type{Crop}){N}(indexes::NTuple{N,AbstractUnitRange})
        new{typeof(indexes)}(indexes)
    end
end
Crop{N}(indexes::Vararg{AbstractUnitRange,N}) = Crop(indexes)
Crop(x, y, width, height) = Crop(y:y+height-1, x:x+width-1)
Crop(; x = 1, y = 1, width = 64, height = 64) = Crop(x, y, width, height)

Base.show(io::IO, op::Crop) = print(io, "Crop region $(op.indexes)")

islazy{T<:Crop}(::Type{T}) = true
applyeager(tfm::Crop, img) = plain_array(img[tfm.indexes...])
applylazy(tfm::Crop, img) = view(img, map(IdentityRange, tfm.indexes)...)
