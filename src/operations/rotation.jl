immutable Rotate90 <: AffineOperation end
Rotate90(p) = Either(Rotate90(), p)
toaffine(::Rotate90, img) = recenter(RotMatrix(pi/2), center(img))
applyeager(::Rotate90, img) = plain_array(rotl90(img))

immutable Rotate180 <: AffineOperation end
Rotate180(p) = Either(Rotate180(), p)
toaffine(::Rotate180, img) = recenter(RotMatrix(pi), center(img))
applyeager(::Rotate180, img) = plain_array(rot180(img))

immutable Rotate270 <: AffineOperation end
Rotate270(p) = Either(Rotate270(), p)
toaffine(::Rotate270, img) = recenter(RotMatrix(-pi/2), center(img))
applyeager(::Rotate270, img) = plain_array(rotr90(img))

for deg in (90, 180, 270)
    T = Symbol(:Rotate, deg)
    @eval function Base.show(io::IO, op::$T)
        if get(io, :compact, false)
            print(io, "Rotate ", $deg, " degree")
        else
            print(io, $T, "()")
        end
    end
end
