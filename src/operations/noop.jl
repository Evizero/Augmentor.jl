"""
    NoOp <: Augmentor.AffineOperation

Identity transformation that does not do anything with the given
image, but instead passes it along unchanged (without copying).

Usually used in combination with [`Either`](@ref) to denote a
"branch" that does not perform any computation.
"""
struct NoOp <: AffineOperation end

@inline supports_eager(::Type{NoOp}) = false
@inline supports_stepview(::Type{NoOp}) = true
@inline supports_view(::Type{NoOp}) = true

# TODO: implement method for n-dim arrays
toaffinemap(::NoOp, img::AbstractMatrix) = AffineMap(@SMatrix([1. 0; 0 1.]), @SVector([0.,0.]))
applyeager(::NoOp, img::AbstractArray, param) = maybe_copy(img)
applylazy(::NoOp, img::AbstractArray, param) = img

function applyview(::NoOp, img::AbstractArray, param)
    idx = map(i->1:length(i), indices(img))
    indirect_view(img, idx)
end

function applystepview(::NoOp, img::AbstractArray, param)
    idx = map(i->1:1:length(i), indices(img))
    indirect_view(img, idx)
end

function showconstruction(io::IO, op::NoOp)
    print(io, typeof(op).name.name, "()")
end

function Base.show(io::IO, op::NoOp)
    if get(io, :compact, false)
        print(io, "No operation")
    else
        print(io, "Augmentor.")
        showconstruction(io, op)
    end
end
