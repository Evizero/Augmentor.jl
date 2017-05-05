immutable NoOp <: AffineImageTransform end
Base.show(io::IO, op::NoOp) = print(io, "No transformation")

toaffine(::NoOp, img) = AffineMap(@SMatrix([1. 0; 0 1.]), @SVector([0.,0.]))
applyeager(::NoOp, img) = plain_array(img)
