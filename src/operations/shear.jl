"""
    ShearX <: Augmentor.AffineOperation

Description
--------------

Shear the image horizontally for the given `degree`. This
operation can only be performed as an affine transformation and
will in general cause other operations of the pipeline to use
their affine formulation as well (if they have one).

It will always perform the transformation around the center of
the image. This can be particularly useful when combining the
operation with [`CropNative`](@ref).

Usage
--------------

    ShearX(degree)

Arguments
--------------

- **`degree`** : `Real` or `AbstractVector` of `Real` that denote
    the shearing angle(s) in degree. If a vector is provided,
    then a random element will be sampled each time the operation
    is applied.

See also
--------------

[`ShearY`](@ref), [`CropNative`](@ref), [`augment`](@ref)

Examples
--------------

```julia
using Augmentor
img = testpattern()

# shear horizontally exactly 5 degree
augment(img, ShearX(5))

# shear horizontally between 10 and 20 degree to the right
augment(img, ShearX(10:20))

# shear horizontally one of the five specified degrees
augment(img, ShearX([-10, -5, 0, 5, 10]))
```
"""
struct ShearX{T<:AbstractVector} <: AffineOperation
    degree::T

    function ShearX{T}(degree::T) where {T<:AbstractVector{S} where S<:Real}
        length(degree) > 0 || throw(ArgumentError("The number of different angles passed to \"ShearX(...)\" must be non-zero"))
        (minimum(degree) >= -70 && maximum(degree) <= 70) || throw(ArgumentError("The specified shearing angle(s) must be in the interval [-70, 70]"))
        new{T}(degree)
    end
end
ShearX(degree::T) where {T<:AbstractVector} = ShearX{T}(degree)
ShearX(degree::Real) = ShearX(degree:degree)

@inline supports_eager(::Type{<:ShearX}) = false

randparam(op::ShearX, img) = Float64(safe_rand(op.degree))

function toaffinemap(op::ShearX, img::AbstractMatrix, angle)
    recenter(@SMatrix([1. 0.; tan(-deg2rad(Float64(angle))) 1.]), center(img))
end

function Base.show(io::IO, op::ShearX)
    if get(io, :compact, false)
        if length(op.degree) == 1
            print(io, "ShearX ", first(op.degree), " degree")
        else
            print(io, "ShearX by ϕ ∈ ", op.degree, " degree")
        end
    else
        print(io, "Augmentor.")
        showconstruction(io, op)
    end
end

# --------------------------------------------------------------------

"""
    ShearY <: Augmentor.AffineOperation

Description
--------------

Shear the image vertically for the given `degree`. This operation
can only be performed as an affine transformation and will in
general cause other operations of the pipeline to use their
affine formulation as well (if they have one).

It will always perform the transformation around the center of
the image. This can be particularly useful when combining the
operation with [`CropNative`](@ref).

Usage
--------------

    ShearY(degree)

Arguments
--------------

- **`degree`** : `Real` or `AbstractVector` of `Real` that denote
    the shearing angle(s) in degree. If a vector is provided,
    then a random element will be sampled each time the operation
    is applied.

See also
--------------

[`ShearX`](@ref), [`CropNative`](@ref), [`augment`](@ref)

Examples
--------------

```julia
using Augmentor
img = testpattern()

# shear vertically exactly 5 degree
augment(img, ShearY(5))

# shear vertically between 10 and 20 degree upwards
augment(img, ShearY(10:20))

# shear vertically one of the five specified degrees
augment(img, ShearY([-10, -5, 0, 5, 10]))
```
"""
struct ShearY{T<:AbstractVector} <: AffineOperation
    degree::T

    function ShearY{T}(degree::T) where {T<:AbstractVector{S} where S<:Real}
        length(degree) > 0 || throw(ArgumentError("The number of different angles passed to \"ShearY(...)\" must be non-zero"))
        (minimum(degree) >= -70 && maximum(degree) <= 70) || throw(ArgumentError("The specified shearing angle(s) must be in the interval [-70, 70]"))
        new{T}(degree)
    end
end
ShearY(degree::T) where {T<:AbstractVector} = ShearY{T}(degree)
ShearY(degree::Real) = ShearY(degree:degree)

@inline supports_eager(::Type{<:ShearY}) = false

randparam(op::ShearY, img) = Float64(safe_rand(op.degree))

function toaffinemap(op::ShearY, img::AbstractMatrix, angle)
    recenter(@SMatrix([1. tan(-deg2rad(Float64(angle))); 0. 1.]), center(img))
end

function Base.show(io::IO, op::ShearY)
    if get(io, :compact, false)
        if length(op.degree) == 1
            print(io, "ShearY ", first(op.degree), " degree")
        else
            print(io, "ShearY by ψ ∈ ", op.degree, " degree")
        end
    else
        print(io, "Augmentor.")
        showconstruction(io, op)
    end
end

# --------------------------------------------------------------------

function showconstruction(io::IO, op::Union{Rotate,ShearX,ShearY})
    if length(op.degree) == 1
        print(io, typeof(op).name.name, '(', first(op.degree), ')')
    else
        print(io, typeof(op).name.name, '(', op.degree, ')')
    end
end
