immutable Crop{I<:Tuple} <: ImageTransform
    indexes::I

    function (::Type{Crop}){N}(indexes::NTuple{N,AbstractUnitRange})
        new{typeof(indexes)}(indexes)
    end
end
Crop{N}(indexes::Vararg{AbstractUnitRange,N}) = Crop(indexes)
Crop(x::Integer, y::Integer, width::Integer, height::Integer) = Crop(y:y+height-1, x:x+width-1)
Crop(; x = 1, y = 1, width = 64, height = 64) = Crop(x, y, width, height)

islazy{T<:Crop}(::Type{T}) = true
applyeager(tfm::Crop, img) = _toarray(img[tfm.indexes...])
applylazy(tfm::Crop, img) = view(img, map(IdentityRange, tfm.indexes)...)
