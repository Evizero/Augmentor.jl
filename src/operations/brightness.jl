import ImageCore: clamp01
import Statistics: mean

"""
    AdjustContrastBrightness <: ImageOperation

Description
--------------

Adjusts the brightness and contrast of each pixel.

Usage
--------------

    AdjustContrastBrightness(α, β)

Arguments
--------------

- **`α`** : `Real` or `AbstractVector` of `Real` that denote
    the coefficient(s) for contrast adjustment.
- **`β`** : `Real` or `AbstractVector` of `Real` that denote
    the coefficient(s) for brightness adjustment.

Examples
--------------

```
using Augmentor
img = testpattern()

# use exactly 1.2 for contrast, and one of 0.5 and 0.8 for brightness
augment(img, AdjustContrastBrightness(1.2, [0.5, 0.8]))

# pick the coefficients randomly from the specified ranges
augment(img, AdjustContrastBrightness(0.8:0.1:2.0, 0.5:0.1:1.1))
```
"""
struct AdjustContrastBrightness{T<:AbstractVector} <: ImageOperation
    α::T
    β::T

    function AdjustContrastBrightness(α::T, β::T) where {T<:AbstractVector{<:Real}}
        length(α) > 0 || throw(ArgumentError("Range $(α) is empty"))
        length(β) > 0 || throw(ArgumentError("Range $(β) is empty"))
        new{T}(α, β)
    end
end

AdjustContrastBrightness(α, β) = AdjustContrastBrightness(vectorize(α),
                                                          vectorize(β))

randparam(op::AdjustContrastBrightness, img) = (safe_rand(op.α), safe_rand(op.β))

@inline supports_eager(::AdjustContrastBrightness) = true
@inline supports_lazy(::AdjustContrastBrightness) = true

function applyeager(op::AdjustContrastBrightness, img::AbstractArray, (α, β))
    M = _get_M(op, img)
    return _map_pix.(α, β, M, img)
end

function applylazy(op::AdjustContrastBrightness, img::AbstractArray, (α, β))
    M = _get_M(op, img)
    return AdjustedView(img, α, β, M)
end

function showconstruction(io::IO, op::AdjustContrastBrightness)
    print(io, typeof(op).name.name, '(', op.α, ", ", op.β,')')
end

function Base.show(io::IO, op::AdjustContrastBrightness)
    if get(io, :compact, false)
        print(io, "Adjust contrast & brightness with coffecients from $(op.α) and $(op.β), respectively")
    else
        print(io, "Augmentor.")
        showconstruction(io, op)
    end
end

_map_pix(α, β, M, pix) = clamp01(α * pix + β * M)
_get_M(op::AdjustContrastBrightness, img) = mean(img)

# This wraps an image so that its pixels appear as after the contrast and
# brightness adjustment. This is done in the `getindex` method.
struct AdjustedView{T, P<:AbstractMatrix{T}, R} <: AbstractArray{T, 2}
    orig::P
    α::R
    β::R
    M::T

    function AdjustedView(img::P, α::R, β::R, M) where {P <: AbstractMatrix,
                                                        R <: Real}
        new{eltype(P), P, R}(img, α, β, M)
    end
end

Base.parent(A::AdjustedView) = A.parent
Base.size(A::AdjustedView) = size(A.orig)
Base.axes(A::AdjustedView) = axes(A.orig)
Base.getindex(A::AdjustedView, i, j) = _map_pix(A.α, A.β, A.M, A.orig[i, j])
