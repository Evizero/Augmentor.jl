import ImageFiltering: imfilter, KernelFactors.gaussian

"""
    GaussianBlur <: ColorOperation

Description
--------------

Blurs an image using a Gaussian filter.

Usage
--------------

    GaussianBlur(k, [σ])

Arguments
--------------

- **`k`** : `Integer` or `AbstractVector` of `Integer` that denote
    the kernel size. It must be an odd positive number.
- **`σ`** : Optional. `Real` or `AbstractVector` of `Real` that denote the
    standard deviation. It must be a positive number.
    Defaults to `0.3 * ((k - 1) / 2 - 1) + 0.8`.

Examples
--------------

```
using Augmentor
img = testpattern()

# use exactly k=3 and σ=1.0
augment(img, GaussianBlur(3, 1.0))

# pick k and σ randomly from the specified ranges
augment(img, GaussianBlur(3:2:7, 1.0:0.1:2.0))
```
"""
struct GaussianBlur{K <: AbstractVector, S <: AbstractVector} <: ColorOperation
    k::K
    σ::S

    function GaussianBlur(k::K, σ::S) where {K <: AbstractVector{<:Integer},
                                             S <: AbstractVector{<:Real}}
        minimum(k) > 0 || throw(ArgumentError("Kernel size must be positive: $(k)"))
        minimum(σ) > 0 || throw(ArgumentError("σ must be positive: $(σ)"))
        new{K, S}(k, σ)
    end
end

# The default value for σ is taken from Albumentations
GaussianBlur(k) = GaussianBlur(k, 0.3 * ((k - 1) / 2 - 1) + 0.8)
GaussianBlur(k, σ) = GaussianBlur(vectorize(k), vectorize(σ))

randparam(op::GaussianBlur, img) = (safe_rand(op.k), safe_rand(op.σ))

@inline supports_eager(::Type{<:GaussianBlur}) = true

function applyeager(op::GaussianBlur, img::AbstractArray, (k, σ))
    n = ndims(img)
    kernel = gaussian(ntuple(_->σ, n), ntuple(_->k, n))
    return imfilter(img, kernel)
end

function showconstruction(io::IO, op::GaussianBlur)
    print(io, typeof(op).name.name, '(', op.k, ", ", op.σ,')')
end

function Base.show(io::IO, op::GaussianBlur)
    if get(io, :compact, false)
        print(io, "GaussianBlur with k=$(op.k) and σ=$(op.σ)")
    else
        print(io, "Augmentor.")
        showconstruction(io, op)
    end
end
