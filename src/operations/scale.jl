"""
    Scale <: Augmentor.AffineOperation

Description
--------------

Multiplies the image height and image width by the specified
`factors`. This means that the size of the output image depends
on the size of the input image.

The provided `factors` can either be numbers or vectors of
numbers.

- If numbers are provided, then the operation is deterministic
  and will always scale the input image with the same factors.

- In the case vectors are provided, then each time the operation
  is applied a valid index is sampled and the elements
  corresponding to that index are used as scaling factors.

The scaling is performed relative to the image center, which can
be useful when following the operation with [`CropNative`](@ref).

Usage
--------------

    Scale(factors)

    Scale(factors...)

Arguments
--------------

- **`factors`** : `NTuple` or `Vararg` of `Real` or
    `AbstractVector` that denote the scale factor(s) for each
    array dimension. If only one variable is specified it is
    assumed that height and width should be scaled by the same
    factor(s).

See also
--------------

[`Zoom`](@ref), [`Resize`](@ref), [`augment`](@ref)

Examples
--------------

```julia
using Augmentor
img = testpattern()

# half the image size
augment(img, Scale(0.5))

# uniformly scale by a random factor from 1.2, 1.3, or 1.4
augment(img, Scale([1.2, 1.3, 1.4]))

# scale by either 0.5x0.7 or by 0.6x0.8
augment(img, Scale([0.5, 0.6], [0.7, 0.8]))
```
"""
struct Scale{N,T<:AbstractVector} <: AffineOperation
    factors::NTuple{N,T}

    function Scale{N}(factors::NTuple{N,T}) where {N,T<:AbstractVector}
        eltype(T) <: Real || throw(ArgumentError("The specified factors must be vectors of Real. Actual: $T"))
        n = length(factors[1])
        n > 0 || throw(ArgumentError("The specified factors must all have a length greater than 0"))
        all(f->length(f)==n, factors) || throw(ArgumentError("The specified factors must all be of the same length for each dimension. Actual: $(factors)"))
        new{N,T}(factors)
    end
end
Scale() = throw(MethodError(Scale, ()))
Scale(::Tuple{}) = throw(MethodError(Scale, ((),)))
Scale(factors...) = Scale(factors)
Scale(factor::Union{AbstractVector,Real}) = Scale((factor, factor))
Scale(factors::NTuple{N,Any}) where {N} = Scale(map(vectorize, factors))
Scale(factors::NTuple{N,Range}) where {N} = Scale{N}(promote(factors...))
function Scale(factors::NTuple{N,AbstractVector}) where N
    Scale{N}(map(Vector{Float64}, factors))
end
function (::Type{Scale{N}})(factors::NTuple{N,Any}) where N
    Scale(map(vectorize, factors))
end

@inline supports_eager(::Type{<:Scale}) = false

randparam(op::Scale, imgs::Tuple) = randparam(op, imgs[1])

function randparam(op::Scale, img::AbstractArray{T,N}) where {T,N}
    i = safe_rand(1:length(op.factors[1]))
    ntuple(j -> Float64(op.factors[j][i]), Val{N})
end

function toaffinemap(op::Scale{2}, img::AbstractMatrix, idx)
    @inbounds tfm = recenter(@SMatrix([Float64(idx[1]) 0.; 0. Float64(idx[2])]), center(img))
    tfm
end

function showconstruction(io::IO, op::Scale)
    fct = length(op.factors[1]) == 1 ? map(first,op.factors) : op.factors
    print(io, typeof(op).name.name, '(', join(map(string, fct),", "), ')')
end

function Base.show(io::IO, op::Scale{N}) where N
    if get(io, :compact, false)
        str = join(map(t->join(t,"×"), collect(zip(op.factors...))), ", ")
        if length(op.factors[1]) == 1
            print(io, "Scale by $(str)")
        else
            print(io, "Scale by I ∈ {$(str)}")
        end
    else
        fct = length(op.factors[1]) == 1 ? map(first,op.factors) : op.factors
        print(io, typeof(op).name, "{$N}($(fct))")
    end
end
