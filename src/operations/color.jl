import ImageCore: clamp01, gamutmax
import Statistics: mean

"""
    ColorJitter <: ImageOperation

Description
--------------

Adjusts the brightness and contrast of an image according to the formula
`α * image[i] + β * M`, where `M` is either `mean(image)` or the maximum
intensity value.

Usage
--------------

    ColorJitter()
    ColorJitter(α, β; [usemax])

Arguments
--------------

- **`α`** : `Real` or `AbstractVector` of `Real` that denote the coefficient(s)
    for contrast adjustment. Defaults to `0.8:0.1:1.2`.
- **`β`** : `Real` or `AbstractVector` of `Real` that denote the coefficient(s)
    for brightness adjustment. Defaults to `-0.2:0.1:0.2`.
- **`usemax::Bool`**: Optional. If `true`, the brightness will be adjusted by
    the maximum intensity value; otherwise, the image mean will be used.
    Defaults to `true`.

Examples
--------------

```
using Augmentor
img = testpattern()

# use exactly 1.2 for contrast, and one of 0.5 and 0.8 for brightness
augment(img, ColorJitter(1.2, [0.5, 0.8]))

# pick the coefficients randomly from the specified ranges
augment(img, ColorJitter(0.8:0.1:2.0, 0.5:0.1:1.1))
```
"""
struct ColorJitter{A<:AbstractVector, B<:AbstractVector} <: ImageOperation
    α::A
    β::B
    usemax::Bool

    function ColorJitter(α::A, β::B, usemax) where {A<:AbstractVector{<:Real},
                                                    B<:AbstractVector{<:Real}}
        length(α) > 0 || throw(ArgumentError("Range $(α) is empty"))
        length(β) > 0 || throw(ArgumentError("Range $(β) is empty"))
        new{A, B}(α, β, usemax)
    end
end

ColorJitter() = ColorJitter(0.8:0.1:1.2, -0.2:0.1:0.2, true)
ColorJitter(α, β; usemax=true) = ColorJitter(vectorize(α), vectorize(β), usemax)

randparam(op::ColorJitter, img) = (safe_rand(op.α), safe_rand(op.β))

@inline supports_eager(::Type{<:ColorJitter}) = true
@inline supports_lazy(::Type{<:ColorJitter}) = true

function applyeager(op::ColorJitter, img::AbstractArray, (α, β))
    M = _get_M(op, img)
    return _map_pix.(α, β, M, img)
end

function applylazy(op::ColorJitter, img::AbstractArray, (α, β))
    M = _get_M(op, img)
    return ColorJitterView(img, α, β, M)
end

function showconstruction(io::IO, op::ColorJitter)
    print(io, typeof(op).name.name, '(', op.α, ", ", op.β, ", ", op.usemax, ')')
end

function Base.show(io::IO, op::ColorJitter)
    if get(io, :compact, false)
        maxmsg = op.usemax ? "max. intensity" : "mean value";
        print(io, "Color jitter with coffecients α=$(op.α) and β=$(op.β) (w.r.t. $(maxmsg))")
    else
        print(io, "Augmentor.")
        showconstruction(io, op)
    end
end

_map_pix(α, β, M, pix) = clamp01(α * pix + β * M)
function _get_M(op::ColorJitter, img)
    M = op.usemax ? gamutmax(eltype(img)) : mean(img)
    T = eltype(img)
    return T(M...)
end

# This wraps an image so that its pixels appear as after the contrast and
# brightness adjustment. This is done in the `getindex` method.
struct ColorJitterView{T, P<:AbstractMatrix{T}, R} <: AbstractArray{T, 2}
    orig::P
    α::R
    β::R
    M::T

    function ColorJitterView(img::P, α::R, β::R, M) where {P <: AbstractMatrix,
                                                        R <: Real}
        new{eltype(P), P, R}(img, α, β, M)
    end
end

Base.parent(A::ColorJitterView) = A.parent
Base.size(A::ColorJitterView) = size(A.orig)
Base.axes(A::ColorJitterView) = axes(A.orig)
Base.getindex(A::ColorJitterView, i, j) = _map_pix(A.α, A.β, A.M, A.orig[i, j])
