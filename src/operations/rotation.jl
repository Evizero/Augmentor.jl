# TODO: implement methods for n-dim arrays

immutable Rotate90 <: AffineOperation end
Rotate90(p) = Either(Rotate90(), p)

Base.@pure supports_permute(::Type{Rotate90}) = true

toaffine(::Rotate90, img::AbstractMatrix) = recenter(RotMatrix(pi/2), center(img))
applyeager(::Rotate90, img::AbstractMatrix) = plain_array(rotl90(img))
applylazy_fallback(op::Rotate90, img::AbstractMatrix) = applypermute(op, img)

function applypermute{T}(::Rotate90, img::AbstractMatrix{T})
    idx = map(StepRange, indices(img))
    perm_img = PermutedDimsArray{T,2,(2,1),(2,1),typeof(img)}(img)
    view(perm_img, reverse(idx[2]), idx[1])
end

function applypermute{T,IT<:PermutedDimsArray}(::Rotate90, sub::SubArray{T,2,IT})
    # this is just a sanity check that should never be violated
    @assert IT <: PermutedDimsArray{T,2,(2,1)}
    idx = map(StepRange, sub.indexes)
    img = parent(parent(sub))
    view(img, reverse(idx[2]), idx[1])
end

# --------------------------------------------------------------------

immutable Rotate180 <: AffineOperation end
Rotate180(p) = Either(Rotate180(), p)

Base.@pure supports_stepview(::Type{Rotate180}) = true

toaffine(::Rotate180, img::AbstractMatrix) = recenter(RotMatrix(pi), center(img))
applyeager(::Rotate180, img::AbstractMatrix) = plain_array(rot180(img))
applylazy_fallback(op::Rotate180, img::AbstractMatrix) = applystepview(op, img)

function applystepview(::Rotate180, img::AbstractMatrix)
    idx = map(i->1:1:length(i), indices(img))
    identity_view(img, (reverse(idx[1]), reverse(idx[2])))
end

# --------------------------------------------------------------------

immutable Rotate270 <: AffineOperation end
Rotate270(p) = Either(Rotate270(), p)

Base.@pure supports_permute(::Type{Rotate270}) = true

toaffine(::Rotate270, img::AbstractMatrix) = recenter(RotMatrix(-pi/2), center(img))
applyeager(::Rotate270, img::AbstractMatrix) = plain_array(rotr90(img))
applylazy_fallback(op::Rotate270, img::AbstractMatrix) = applypermute(op, img)

function applypermute{T}(::Rotate270, img::AbstractMatrix{T})
    idx = map(StepRange, indices(img))
    perm_img = PermutedDimsArray{T,2,(2,1),(2,1),typeof(img)}(img)
    view(perm_img, idx[2], reverse(idx[1]))
end

function applypermute{T,IT<:PermutedDimsArray}(::Rotate270, sub::SubArray{T,2,IT})
    # this is just a sanity check that should never be violated
    @assert IT <: PermutedDimsArray{T,2,(2,1)}
    idx = map(StepRange, sub.indexes)
    img = parent(parent(sub))
    view(img, idx[2], reverse(idx[1]))
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
