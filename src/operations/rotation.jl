immutable Rotate90 <: AffineOperation end
Rotate90(p) = Either(Rotate90(), p)

Base.@pure supports_permute(::Type{Rotate90}) = true

toaffine(::Rotate90, img) = recenter(RotMatrix(pi/2), center(img))
applyeager(::Rotate90, img) = plain_array(rotl90(img))
applylazy(op::Rotate90, img) = applypermute(op, img)

function applypermute{T}(::Rotate90, img::AbstractMatrix{T})
    idx = map(StepRange, indices(img))
    perm_img = PermutedDimsArray{T,2,(2,1),(2,1),typeof(img)}(img)
    view(perm_img, reverse(idx[1]), idx[2])
end

# --------------------------------------------------------------------

immutable Rotate180 <: AffineOperation end
Rotate180(p) = Either(Rotate180(), p)

Base.@pure supports_stepview(::Type{Rotate180}) = true

toaffine(::Rotate180, img) = recenter(RotMatrix(pi), center(img))
applyeager(::Rotate180, img) = plain_array(rot180(img))
applylazy(op::Rotate180, img) = applystepview(op, img)

function applystepview(::Rotate180, img::AbstractMatrix)
    idx = map(StepRange, indices(img))
    view(img, reverse(idx[1]), reverse(idx[2]))
end

# --------------------------------------------------------------------

immutable Rotate270 <: AffineOperation end
Rotate270(p) = Either(Rotate270(), p)

Base.@pure supports_permute(::Type{Rotate270}) = true

toaffine(::Rotate270, img) = recenter(RotMatrix(-pi/2), center(img))
applyeager(::Rotate270, img) = plain_array(rotr90(img))
applylazy(op::Rotate270, img) = applypermute(op, img)

function applypermute{T}(::Rotate270, img::AbstractMatrix{T})
    idx = map(StepRange, indices(img))
    perm_img = PermutedDimsArray{T,2,(2,1),(2,1),typeof(img)}(img)
    view(perm_img, idx[1], reverse(idx[2]))
end

# --------------------------------------------------------------------

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
