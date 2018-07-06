"""
    Zoom <: Augmentor.ImageOperation

Description
--------------

Scales the image height and image width by the specified
`factors`, but crops the image such that the original size is
preserved.

The provided `factors` can either be numbers or vectors of
numbers.

- If numbers are provided, then the operation is deterministic
  and will always scale the input image with the same factors.

- In the case vectors are provided, then each time the operation
  is applied a valid index is sampled and the elements
  corresponding to that index are used as scaling factors.

In contrast to [`Scale`](@ref) the size of the output image is
the same as the size of the input image, while the content is
scaled the same way. The same effect could be achieved by
following a [`Scale`](@ref) with a [`CropSize`](@ref), with the
caveat that one would need to know the exact size of the input
image before-hand.

Usage
--------------

    Zoom(factors)

    Zoom(factors...)

Arguments
--------------

- **`factors`** : `NTuple` or `Vararg` of `Real` or
    `AbstractVector` that denote the scale factor(s) for each
    array dimension. If only one variable is specified it is
    assumed that height and width should be scaled by the same
    factor(s).

See also
--------------

[`Scale`](@ref), [`Resize`](@ref), [`augment`](@ref)

Examples
--------------

```julia
using Augmentor
img = testpattern()

# half the image size
augment(img, Zoom(0.5))

# uniformly scale by a random factor from 1.2, 1.3, or 1.4
augment(img, Zoom([1.2, 1.3, 1.4]))

# scale by either 0.5x0.7 or by 0.6x0.8
augment(img, Zoom([0.5, 0.6], [0.7, 0.8]))
```
"""
struct Zoom{N,T<:AbstractVector} <: ImageOperation
    factors::NTuple{N,T}

    function Zoom{N}(factors::NTuple{N,T}) where {N,T<:AbstractVector}
        eltype(T) <: Real || throw(ArgumentError("The specified factors must be vectors of Real. Actual: $T"))
        n = length(factors[1])
        n > 0 || throw(ArgumentError("The specified factors must all have a length greater than 0"))
        all(f->length(f)==n, factors) || throw(ArgumentError("The specified factors must all be of the same length for each dimension. Actual: $(factors)"))
        new{N,T}(factors)
    end
end
Zoom() = throw(MethodError(Zoom, ()))
Zoom(::Tuple{}) = throw(MethodError(Zoom, ((),)))
Zoom(factors...) = Zoom(factors)
Zoom(factor::Union{AbstractVector,Real}) = Zoom((factor, factor))
Zoom(factors::NTuple{N,Any}) where {N} = Zoom(map(vectorize, factors))
Zoom(factors::NTuple{N,Range}) where {N} = Zoom{N}(promote(factors...))
function Zoom(factors::NTuple{N,AbstractVector}) where N
    Zoom{N}(map(Vector{Float64}, factors))
end
function (::Type{Zoom{N}})(factors::NTuple{N,Any}) where N
    Zoom(map(vectorize, factors))
end

@inline supports_affineview(::Type{<:Zoom}) = true
@inline supports_eager(::Type{<:Zoom}) = false

randparam(op::Zoom, imgs::Tuple) = randparam(op, imgs[1])

function randparam(op::Zoom, img::AbstractArray{T,N}) where {T,N}
    i = safe_rand(1:length(op.factors[1]))
    ntuple(j -> Float64(op.factors[j][i]), Val{N})
end

function toaffinemap(op::Zoom{2}, img::AbstractMatrix, idx)
    @inbounds tfm = recenter(@SMatrix([Float64(idx[1]) 0.; 0. Float64(idx[2])]), center(img))
    tfm
end

function applylazy(op::Zoom, img::AbstractArray, idx)
    applyaffineview(op, prepareaffine(img), idx)
end

function applyaffineview(op::Zoom{N}, img::AbstractArray{T,N}, idx) where {T,N}
    wv = invwarpedview(img, toaffinemap(op, img, idx), indices(img))
    direct_view(wv, indices(img))
end

function applyaffineview(op::Zoom{N}, v::SubArray{T,N,<:InvWarpedView}, idx) where {T,N}
    tinv = toaffinemap(op, v, idx)
    img = parent(v)
    nidx = ImageTransformations.autorange(img, tinv)
    wv = InvWarpedView(img, tinv, map(unionrange, nidx, indices(img)))
    view(wv, v.indexes...)
end

function showconstruction(io::IO, op::Zoom)
    fct = length(op.factors[1]) == 1 ? map(first,op.factors) : op.factors
    print(io, typeof(op).name.name, '(', join(map(string, fct),", "), ')')
end

function Base.show(io::IO, op::Zoom{N}) where N
    if get(io, :compact, false)
        str = join(map(t->join(round_if_float(t,2),"×"), collect(zip(op.factors...))), ", ")
        if length(op.factors[1]) == 1
            print(io, "Zoom by $(str)")
        else
            print(io, "Zoom by I ∈ {$(str)}")
        end
    else
        fct = length(op.factors[1]) == 1 ? map(first,op.factors) : op.factors
        print(io, typeof(op).name, "{$N}($(fct))")
    end
end
