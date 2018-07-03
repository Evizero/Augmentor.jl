# TODO: implement methods for n-dim arrays

"""
    FlipX <: Augmentor.AffineOperation

Description
--------------

Reverses the x-order of each pixel row. Another way of describing
it would be that it mirrors the image on the y-axis, or that it
mirrors the image horizontally.

If created using the parameter `p`, the operation will be lifted
into `Either(p=>FlipX(), 1-p=>NoOp())`, where `p` denotes the
probability of applying `FlipX` and `1-p` the probability for
applying [`NoOp`](@ref). See the documentation of
[`Either`](@ref) for more information.

Usage
--------------

    FlipX()

    FlipX(p)

Arguments
--------------

- **`p::Number`** : Optional. Probability of applying the
    operation. Must be in the interval [0,1].

See also
--------------

[`FlipY`](@ref), [`Either`](@ref), [`augment`](@ref)

Examples
--------------

```jldoctest
julia> using Augmentor

julia> img = [200 150; 50 1]
2×2 Array{Int64,2}:
 200  150
  50    1

julia> img_new = augment(img, FlipX())
2×2 Array{Int64,2}:
 150  200
   1   50
```
"""
struct FlipX <: AffineOperation end
FlipX(p::Number) = Either(FlipX(), p)

@inline supports_stepview(::Type{FlipX}) = true

toaffinemap(::FlipX, img::AbstractMatrix) = recenter(@SMatrix([1. 0; 0 -1.]), center(img))
# Base.flipdim not type-stable for AbstractArray's
applyeager(::FlipX, img::Array, param) = plain_array(flipdim(img,2))
applyeager(op::FlipX, img::AbstractArray, param) = plain_array(applystepview(op, img, param))
applylazy_fallback(op::FlipX, img::AbstractMatrix, param) = applystepview(op, img, param)

function applystepview(::FlipX, img::AbstractMatrix, param)
    idx = map(i->1:1:length(i), indices(img))
    indirect_view(img, (idx[1], reverse(idx[2])))
end

function showconstruction(io::IO, op::FlipX)
    print(io, typeof(op).name.name, "()")
end

function Base.show(io::IO, op::FlipX)
    if get(io, :compact, false)
        print(io, "Flip the X axis")
    else
        print(io, "Augmentor.")
        showconstruction(io, op)
    end
end

# --------------------------------------------------------------------

"""
    FlipY <: Augmentor.AffineOperation

Description
--------------

Reverses the y-order of each pixel column. Another way of
describing it would be that it mirrors the image on the x-axis,
or that it mirrors the image vertically.

If created using the parameter `p`, the operation will be lifted
into `Either(p=>FlipY(), 1-p=>NoOp())`, where `p` denotes the
probability of applying `FlipY` and `1-p` the probability for
applying [`NoOp`](@ref). See the documentation of
[`Either`](@ref) for more information.

Usage
--------------

    FlipY()

    FlipY(p)

Arguments
--------------

- **`p::Number`** : Optional. Probability of applying the
    operation. Must be in the interval [0,1].

See also
--------------

[`FlipX`](@ref), [`Either`](@ref), [`augment`](@ref)

Examples
--------------

```jldoctest
julia> using Augmentor

julia> img = [200 150; 50 1]
2×2 Array{Int64,2}:
 200  150
  50    1

julia> img_new = augment(img, FlipY())
2×2 Array{Int64,2}:
  50    1
 200  150
```
"""
struct FlipY <: AffineOperation end
FlipY(p::Number) = Either(FlipY(), p)

@inline supports_stepview(::Type{FlipY}) = true

toaffinemap(::FlipY, img::AbstractMatrix) = recenter(@SMatrix([-1. 0; 0 1.]), center(img))
# Base.flipdim not type-stable for AbstractArray's
applyeager(::FlipY, img::Array, param) = plain_array(flipdim(img,1))
applyeager(op::FlipY, img::AbstractArray, param) = plain_array(applystepview(op, img, param))
applylazy_fallback(op::FlipY, img::AbstractMatrix, param) = applystepview(op, img, param)

function applystepview(::FlipY, img::AbstractMatrix, param)
    idx = map(i->1:1:length(i), indices(img))
    indirect_view(img, (reverse(idx[1]), idx[2]))
end

function showconstruction(io::IO, op::FlipY)
    print(io, typeof(op).name.name, "()")
end

function Base.show(io::IO, op::FlipY)
    if get(io, :compact, false)
        print(io, "Flip the Y axis")
    else
        print(io, "Augmentor.")
        showconstruction(io, op)
    end
end
