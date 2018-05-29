# TODO: implement methods for n-dim arrays

"""
    Rotate90 <: Augmentor.AffineOperation

Description
--------------

Rotates the image upwards 90 degrees. This is a special case
rotation because it can be performed very efficiently by simply
rearranging the existing pixels. However, it is generally not the
case that the output image will have the same size as the input
image, which is something to be aware of.

If created using the parameter `p`, the operation will be lifted
into `Either(p=>Rotate90(), 1-p=>NoOp())`, where `p` denotes the
probability of applying `Rotate90` and `1-p` the probability for
applying [`NoOp`](@ref). See the documentation of
[`Either`](@ref) for more information.

Usage
--------------

    Rotate90()

    Rotate90(p)

Arguments
--------------

- **`p::Number`** : Optional. Probability of applying the
    operation. Must be in the interval [0,1].

See also
--------------

[`Rotate180`](@ref), [`Rotate270`](@ref), [`Rotate`](@ref),
[`Either`](@ref), [`augment`](@ref)

Examples
--------------

```jldoctest
julia> using Augmentor

julia> img = [200 150; 50 1]
2×2 Array{Int64,2}:
 200  150
  50    1

julia> img_new = augment(img, Rotate90())
2×2 Array{Int64,2}:
 150   1
 200  50
```
"""
struct Rotate90 <: AffineOperation end
Rotate90(p::Number) = Either(Rotate90(), p)

@inline supports_permute(::Type{Rotate90}) = true

toaffinemap(::Rotate90, img::AbstractMatrix) = recenter(RotMatrix(pi/2), center(img))
applyeager(::Rotate90, img::AbstractMatrix, param) = plain_array(rotl90(img))
applylazy_fallback(op::Rotate90, img::AbstractMatrix, param) = applypermute(op, img, param)

function applypermute(::Rotate90, img::AbstractMatrix{T}, param) where T
    idx = map(StepRange, indices(img))
    perm_img = PermutedDimsArray{T,2,(2,1),(2,1),typeof(img)}(img)
    view(perm_img, reverse(idx[2]), idx[1])
end

function applypermute(::Rotate90, sub::SubArray{T,2,IT,<:NTuple{2,Range}}, param) where {T,IT<:PermutedDimsArray{T,2,(2,1)}}
    idx = map(StepRange, sub.indexes)
    img = parent(parent(sub))
    view(img, reverse(idx[2]), idx[1])
end

function applypermute(::Rotate90, sub::SubArray{T,2,IT,<:NTuple{2,Range}}, param) where {T,IT}
    idx = map(StepRange, sub.indexes)
    img = parent(sub)
    perm_img = PermutedDimsArray{T,2,(2,1),(2,1),typeof(img)}(img)
    view(perm_img, reverse(idx[2]), idx[1])
end

# --------------------------------------------------------------------

"""
    Rotate180 <: Augmentor.AffineOperation

Description
--------------

Rotates the image 180 degrees. This is a special case rotation
because it can be performed very efficiently by simply
rearranging the existing pixels. Furthermore, the output image
will have the same dimensions as the input image.

If created using the parameter `p`, the operation will be lifted
into `Either(p=>Rotate180(), 1-p=>NoOp())`, where `p` denotes the
probability of applying `Rotate180` and `1-p` the probability for
applying [`NoOp`](@ref). See the documentation of
[`Either`](@ref) for more information.

Usage
--------------

    Rotate180()

    Rotate180(p)

Arguments
--------------

- **`p::Number`** : Optional. Probability of applying the
    operation. Must be in the interval [0,1].

See also
--------------

[`Rotate90`](@ref), [`Rotate270`](@ref), [`Rotate`](@ref),
[`Either`](@ref), [`augment`](@ref)

Examples
--------------

```jldoctest
julia> using Augmentor

julia> img = [200 150; 50 1]
2×2 Array{Int64,2}:
 200  150
  50    1

julia> img_new = augment(img, Rotate180())
2×2 Array{Int64,2}:
   1   50
 150  200
```
"""
struct Rotate180 <: AffineOperation end
Rotate180(p::Number) = Either(Rotate180(), p)

@inline supports_stepview(::Type{Rotate180}) = true

toaffinemap(::Rotate180, img::AbstractMatrix) = recenter(RotMatrix(pi), center(img))
applyeager(::Rotate180, img::AbstractMatrix, param) = plain_array(rot180(img))
applylazy_fallback(op::Rotate180, img::AbstractMatrix, param) = applystepview(op, img, param)

function applystepview(::Rotate180, img::AbstractMatrix, param)
    idx = map(i->1:1:length(i), indices(img))
    indirect_view(img, (reverse(idx[1]), reverse(idx[2])))
end

# --------------------------------------------------------------------

"""
    Rotate270 <: Augmentor.AffineOperation

Description
--------------

Rotates the image upwards 270 degrees, which can also be
described as rotating the image downwards 90 degrees. This is a
special case rotation, because it can be performed very
efficiently by simply rearranging the existing pixels. However,
it is generally not the case that the output image will have the
same size as the input image, which is something to be aware of.

If created using the parameter `p`, the operation will be lifted
into `Either(p=>Rotate270(), 1-p=>NoOp())`, where `p` denotes the
probability of applying `Rotate270` and `1-p` the probability for
applying [`NoOp`](@ref). See the documentation of
[`Either`](@ref) for more information.

Usage
--------------

    Rotate270()

    Rotate270(p)

Arguments
--------------

- **`p::Number`** : Optional. Probability of applying the
    operation. Must be in the interval [0,1].

See also
--------------

[`Rotate90`](@ref), [`Rotate180`](@ref), [`Rotate`](@ref),
[`Either`](@ref), [`augment`](@ref)

Examples
--------------

```jldoctest
julia> using Augmentor

julia> img = [200 150; 50 1]
2×2 Array{Int64,2}:
 200  150
  50    1

julia> img_new = augment(img, Rotate270())
2×2 Array{Int64,2}:
 50  200
  1  150
```
"""
struct Rotate270 <: AffineOperation end
Rotate270(p::Number) = Either(Rotate270(), p)

@inline supports_permute(::Type{Rotate270}) = true

toaffinemap(::Rotate270, img::AbstractMatrix) = recenter(RotMatrix(-pi/2), center(img))
applyeager(::Rotate270, img::AbstractMatrix, param) = plain_array(rotr90(img))
applylazy_fallback(op::Rotate270, img::AbstractMatrix, param) = applypermute(op, img, param)

function applypermute(::Rotate270, img::AbstractMatrix{T}, param) where T
    idx = map(StepRange, indices(img))
    perm_img = PermutedDimsArray{T,2,(2,1),(2,1),typeof(img)}(img)
    view(perm_img, idx[2], reverse(idx[1]))
end

function applypermute(::Rotate270, sub::SubArray{T,2,IT,<:NTuple{2,Range}}, param) where {T,IT<:PermutedDimsArray{T,2,(2,1)}}
    idx = map(StepRange, sub.indexes)
    img = parent(parent(sub))
    view(img, idx[2], reverse(idx[1]))
end

function applypermute(::Rotate270, sub::SubArray{T,2,IT,<:NTuple{2,Range}}, param) where {T,IT}
    idx = map(StepRange, sub.indexes)
    img = parent(sub)
    perm_img = PermutedDimsArray{T,2,(2,1),(2,1),typeof(img)}(img)
    view(perm_img, idx[2], reverse(idx[1]))
end

# --------------------------------------------------------------------

for deg in (90, 180, 270)
    T = Symbol(:Rotate, deg)
    @eval function showconstruction(io::IO, op::$T)
        print(io, typeof(op).name.name, "()")
    end
    @eval function Base.show(io::IO, op::$T)
        if get(io, :compact, false)
            print(io, "Rotate ", $deg, " degree")
        else
            print(io, $T, "()")
        end
    end
end

# --------------------------------------------------------------------

"""
    Rotate <: Augmentor.AffineOperation

Description
--------------

Rotate the image upwards for the given `degree`. This operation
can only be performed as an affine transformation and will in
general cause other operations of the pipeline to use their
affine formulation as well (if they have one).

In contrast to the special case rotations (e.g.
[`Rotate90`](@ref), the type `Rotate` can describe any arbitrary
number of degrees. It will always perform the rotation around the
center of the image. This can be particularly useful when
combining the operation with [`CropNative`](@ref).

Usage
--------------

    Rotate(degree)

Arguments
--------------

- **`degree`** : `Real` or `AbstractVector` of `Real` that denote
    the rotation angle(s) in degree. If a vector is provided,
    then a random element will be sampled each time the operation
    is applied.

See also
--------------

[`Rotate90`](@ref), [`Rotate180`](@ref), [`Rotate270`](@ref),
[`CropNative`](@ref), [`augment`](@ref)

Examples
--------------

```julia
using Augmentor
img = testpattern()

# rotate exactly 45 degree
augment(img, Rotate(45))

# rotate between 10 and 20 degree upwards
augment(img, Rotate(10:20))

# rotate one of the five specified degrees
augment(img, Rotate([-10, -5, 0, 5, 10]))
```
"""
struct Rotate{T<:AbstractVector} <: AffineOperation
    degree::T

    function Rotate{T}(degree::T) where {T<:AbstractVector{S} where S<:Real}
        length(degree) > 0 || throw(ArgumentError("The number of different angles passed to \"Rotate(...)\" must be non-zero"))
        new{T}(degree)
    end
end
Rotate(degree::T) where {T<:AbstractVector} = Rotate{T}(degree)
Rotate(degree::Real) = Rotate(degree:degree)

@inline supports_eager(::Type{<:Rotate}) = false

randparam(op::Rotate, img) = Float64(safe_rand(op.degree))

function toaffinemap(op::Rotate, img::AbstractMatrix, angle)
    recenter(RotMatrix(deg2rad(Float64(angle))), center(img))
end

function Base.show(io::IO, op::Rotate)
    if get(io, :compact, false)
        if length(op.degree) == 1
            print(io, "Rotate ", first(op.degree), " degree")
        else
            print(io, "Rotate by θ ∈ ", op.degree, " degree")
        end
    else
        print(io, "Augmentor.")
        showconstruction(io, op)
    end
end
