immutable NoOp <: AffineOperation end

Base.@pure supports_stepview(::Type{NoOp}) = true

toaffine(::NoOp, img) = AffineMap(@SMatrix([1. 0; 0 1.]), @SVector([0.,0.]))
applyeager(::NoOp, img) = plain_array(img)
applylazy(::NoOp, img) = img

function applystepview(::NoOp, img::AbstractArray)
    idx = map(StepRange, indices(img))
    view(img, idx...)
end

function Base.show(io::IO, op::NoOp)
    if get(io, :compact, false)
        print(io, "No operation")
    else
        print(io, typeof(op), "()")
    end
end
