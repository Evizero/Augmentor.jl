import ImageFiltering: imfilter, KernelFactors.gaussian

struct GaussianBlur{K <: AbstractVector, S <: AbstractVector} <: ImageOperation
    k::K
    σ::S

    function GaussianBlur(k::K, σ::S) where {K <: AbstractVector{<:Integer},
                                             S <: AbstractVector{<:Real}}
        minimum(k) > 0 || throw(ArgumentError("Kernel size must be positive: $(k)"))
        minimum(σ) > 0 || throw(ArgumentError("σ must be positive: $(σ)"))
        new{K, S}(k, σ)
    end
end

GaussianBlur(k, σ) = GaussianBlur(vectorize(k), vectorize(σ))

randparam(op::GaussianBlur, img) = (safe_rand(op.k), safe_rand(op.σ))

@inline supports_eager(::GaussianBlur) = true

function applyeager(op::GaussianBlur, img::AbstractArray, (k, σ))
    kernel = gaussian((σ, σ), (k, k))
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

