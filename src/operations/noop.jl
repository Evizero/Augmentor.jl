immutable NoOp <: AffineOperation end

Base.@pure supports_eager(::Type{NoOp}) = false
Base.@pure supports_stepview(::Type{NoOp}) = true
Base.@pure supports_view(::Type{NoOp}) = true

# TODO: implement method for n-dim arrays
toaffine(::NoOp, img::AbstractMatrix) = AffineMap(@SMatrix([1. 0; 0 1.]), @SVector([0.,0.]))
applyeager(::NoOp, img) = plain_array(img)
applylazy(::NoOp, img) = img

function applyview(::NoOp, img)
    idx = map(i->1:length(i), indices(img))
    identity_view(img, idx)
end

function applystepview(::NoOp, img)
    idx = map(i->1:1:length(i), indices(img))
    identity_view(img, idx)
end

function Base.show(io::IO, op::NoOp)
    if get(io, :compact, false)
        print(io, "No operation")
    else
        print(io, typeof(op), "()")
    end
end
