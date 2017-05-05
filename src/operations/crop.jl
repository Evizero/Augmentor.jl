immutable Crop{N,I<:Tuple} <: Operation
    indexes::I

    function (::Type{Crop{N}}){N}(indexes::NTuple{N,AbstractUnitRange})
        new{N,typeof(indexes)}(indexes)
    end
end
Crop{N}(indexes::NTuple{N,AbstractUnitRange}) = Crop{N}(indexes)
Crop{N}(indexes::Vararg{AbstractUnitRange,N}) = Crop{N}(indexes)
Crop(x, y, width, height) = Crop(y:y+height-1, x:x+width-1)
Crop(; x = 1, y = 1, width = 64, height = 64) = Crop(x, y, width, height)

islazy{T<:Crop}(::Type{T}) = true
applyeager(tfm::Crop, img) = plain_array(img[tfm.indexes...])
applylazy(tfm::Crop, img) = view(img, map(IdentityRange, tfm.indexes)...)

function Base.show{N}(io::IO, op::Crop{N})
    if get(io, :compact, false)
        print(io, "Crop region $(op.indexes)")
    else
        print(io, "Augmentor.Crop{$N}($(op.indexes))")
    end
end
