immutable Crop{N,I<:Tuple} <: Operation
    indexes::I

    function (::Type{Crop{N}}){N}(indexes::NTuple{N,UnitRange})
        new{N,typeof(indexes)}(indexes)
    end
end
Crop(::Tuple{}) = throw(MethodError(Crop, ((),)))
Crop{N}(indexes::NTuple{N,UnitRange}) = Crop{N}(indexes)
Crop{N}(indexes::Vararg{UnitRange,N}) = Crop(indexes)
Crop(x, y, width, height) = Crop(y:y+height-1, x:x+width-1)

@inline supports_eager{T<:Crop}(::Type{T})    = false
@inline supports_affine{T<:Crop}(::Type{T})   = true
@inline supports_view{T<:Crop}(::Type{T})     = true
@inline supports_stepview{T<:Crop}(::Type{T}) = true

applyeager(op::Crop, img) = plain_array(indirect_view(img, op.indexes))

applyaffine(op::Crop, img)   = indirect_view(img, op.indexes)
applylazy(op::Crop, img)     = indirect_view(img, op.indexes)
applyview(op::Crop, img)     = indirect_view(img, op.indexes)
applystepview(op::Crop, img) = indirect_view(img, map(StepRange, op.indexes))

function Base.show{N}(io::IO, op::Crop{N})
    if get(io, :compact, false)
        if N == 2
            print(io, "Crop region $(op.indexes[1])×$(op.indexes[2])")
        else
            print(io, "Crop region $(op.indexes)")
        end
    else
        print(io, "Augmentor.Crop{$N}($(op.indexes))")
    end
end

# --------------------------------------------------------------------

immutable CropNative{N,I<:Tuple} <: Operation
    indexes::I

    function (::Type{CropNative{N}}){N}(indexes::NTuple{N,UnitRange})
        new{N,typeof(indexes)}(indexes)
    end
end
CropNative(::Tuple{}) = throw(MethodError(CropNative, ((),)))
CropNative{N}(indexes::NTuple{N,UnitRange}) = CropNative{N}(indexes)
CropNative{N}(indexes::Vararg{UnitRange,N}) = CropNative(indexes)
CropNative(x, y, width, height) = CropNative(y:y+height-1, x:x+width-1)

@inline supports_eager{T<:CropNative}(::Type{T})    = false
@inline supports_affine{T<:CropNative}(::Type{T})   = true
@inline supports_view{T<:CropNative}(::Type{T})     = true
@inline supports_stepview{T<:CropNative}(::Type{T}) = true

applyeager(op::CropNative, img)    = plain_array(img[op.indexes...])
applyaffine(op::CropNative, img)   = direct_view(img, op.indexes)
applylazy(op::CropNative, img)     = direct_view(img, op.indexes)
applyview(op::CropNative, img)     = direct_view(img, op.indexes)
applystepview(op::CropNative, img) = direct_view(img, map(StepRange, op.indexes))

function Base.show{N}(io::IO, op::CropNative{N})
    if get(io, :compact, false)
        if N == 2
            print(io, "Crop native region $(op.indexes[1])×$(op.indexes[2])")
        else
            print(io, "Crop native region $(op.indexes)")
        end
    else
        print(io, "Augmentor.CropNative{$N}($(op.indexes))")
    end
end

# --------------------------------------------------------------------

immutable CropSize{N} <: Operation
    size::NTuple{N,Int}

    function (::Type{CropSize{N}}){N}(size::NTuple{N,Int})
        all(s->s>0, size) || throw(ArgumentError("Specified sizes must be strictly greater than 0. Actual: $size"))
        new{N}(size)
    end
end
CropSize(::Tuple{}) = throw(MethodError(CropSize, ((),)))
CropSize(; width=64, height=64) = CropSize((height,width))
CropSize(size::Vararg{Int}) = CropSize(size)
CropSize{N}(size::NTuple{N,Int}) = CropSize{N}(size)

@inline supports_eager{T<:CropSize}(::Type{T}) = false
@inline supports_affine{T<:CropSize}(::Type{T}) = true
@inline supports_view{T<:CropSize}(::Type{T}) = true
@inline supports_stepview{T<:CropSize}(::Type{T}) = true

function cropsize_indices(op::CropSize, img::AbstractArray)
    cntr = convert(Tuple, center(img))
    sze = op.size
    corner = map((ci,si)->floor(Int,ci)-floor(Int,si/2)+!isinteger(ci), cntr, sze)
    map((b,s)->b:(b+s-1), corner, sze)
end

applyeager(op::CropSize, img)  = plain_array(applyview(op, img))
applylazy(op::CropSize, img)   = applyview(op, img)
applyaffine(op::CropSize, img) = applyview(op, img)

function applyview(op::CropSize, img)
    direct_view(img, cropsize_indices(op, img))
end
function applystepview(op::CropSize, img)
    direct_view(img, map(StepRange, cropsize_indices(op, img)))
end

function Base.show{N}(io::IO, op::CropSize{N})
    if get(io, :compact, false)
        if N == 1
            print(io, "Crop a $(first(op.size))-length window at the center")
        else
            print(io, "Crop a $(join(op.size,"×")) window around the center")
        end
    else
        print(io, "$(typeof(op))($(op.size))")
    end
end
