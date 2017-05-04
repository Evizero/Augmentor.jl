immutable Rotate90 <: AffineImageTransform end
toaffine(::Rotate90, img) = recenter(RotMatrix(pi/2), center(img))
applyeager(::Rotate90, img) = _toarray(rotl90(img))

immutable Rotate180 <: AffineImageTransform end
toaffine(::Rotate180, img) = recenter(RotMatrix(pi), center(img))
applyeager(::Rotate180, img) = _toarray(rot180(img))

immutable Rotate270 <: AffineImageTransform end
toaffine(::Rotate270, img) = recenter(RotMatrix(-pi/2), center(img))
applyeager(::Rotate270, img) = _toarray(rotr90(img))
