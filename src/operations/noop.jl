immutable NoOp <: AffineOperation end

Base.@pure supports_stepview(::Type{NoOp}) = true
Base.@pure supports_view(::Type{NoOp}) = true

toaffine(::NoOp, img) = AffineMap(@SMatrix([1. 0; 0 1.]), @SVector([0.,0.]))
applyeager(::NoOp, img) = plain_array(img)
applylazy(::NoOp, img) = img
applyview(::NoOp, img) = identity_view(img, map(i->1:length(i), indices(img)))

function applystepview(::NoOp, img::AbstractArray)
    idx = map(StepRange, indices(img))
    identity_view(img, idx)
end

function Base.show(io::IO, op::NoOp)
    if get(io, :compact, false)
        print(io, "No operation")
    else
        print(io, typeof(op), "()")
    end
end
