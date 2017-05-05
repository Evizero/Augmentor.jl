immutable Rotate90 <: AffineImageTransform end
Rotate90(p) = Either(Rotate90(), p)
Base.show(io::IO, op::Rotate90) = print(io, "Rotate 90 degrees")
toaffine(::Rotate90, img) = recenter(RotMatrix(pi/2), center(img))
applyeager(::Rotate90, img) = plain_array(rotl90(img))

immutable Rotate180 <: AffineImageTransform end
Rotate180(p) = Either(Rotate180(), p)
Base.show(io::IO, op::Rotate180) = print(io, "Rotate 180 degrees")
toaffine(::Rotate180, img) = recenter(RotMatrix(pi), center(img))
applyeager(::Rotate180, img) = plain_array(rot180(img))

immutable Rotate270 <: AffineImageTransform end
Rotate270(p) = Either(Rotate270(), p)
Base.show(io::IO, op::Rotate270) = print(io, "Rotate 270 degrees")
toaffine(::Rotate270, img) = recenter(RotMatrix(-pi/2), center(img))
applyeager(::Rotate270, img) = plain_array(rotr90(img))

