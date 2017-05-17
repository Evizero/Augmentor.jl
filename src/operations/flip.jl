# TODO: implement methods for n-dim arrays

immutable FlipX <: AffineOperation end
FlipX(p) = Either(FlipX(), p)

@inline supports_stepview(::Type{FlipX}) = true

toaffine(::FlipX, img::AbstractMatrix) = recenter(@SMatrix([1. 0; 0 -1.]), center(img))
# Base.flipdim not type-stable for AbstractArray's
applyeager(::FlipX, img::Array) = plain_array(flipdim(img,2))
applyeager(op::FlipX, img::AbstractArray) = plain_array(applystepview(op, img))
applylazy_fallback(op::FlipX, img::AbstractMatrix) = applystepview(op, img)

function applystepview(::FlipX, img::AbstractMatrix)
    idx = map(i->1:1:length(i), indices(img))
    indirect_view(img, (idx[1], reverse(idx[2])))
end

function Base.show(io::IO, op::FlipX)
    if get(io, :compact, false)
        print(io, "Flip the X axis")
    else
        print(io, "$(typeof(op))()")
    end
end

# --------------------------------------------------------------------

immutable FlipY <: AffineOperation end
FlipY(p) = Either(FlipY(), p)

@inline supports_stepview(::Type{FlipY}) = true

toaffine(::FlipY, img::AbstractMatrix) = recenter(@SMatrix([-1. 0; 0 1.]), center(img))
# Base.flipdim not type-stable for AbstractArray's
applyeager(::FlipY, img::Array) = plain_array(flipdim(img,1))
applyeager(op::FlipY, img::AbstractArray) = plain_array(applystepview(op, img))
applylazy_fallback(op::FlipY, img::AbstractMatrix) = applystepview(op, img)

function applystepview(::FlipY, img::AbstractMatrix)
    idx = map(i->1:1:length(i), indices(img))
    indirect_view(img, (reverse(idx[1]), idx[2]))
end

function Base.show(io::IO, op::FlipY)
    if get(io, :compact, false)
        print(io, "Flip the Y axis")
    else
        print(io, "$(typeof(op))()")
    end
end
