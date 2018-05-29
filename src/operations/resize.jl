"""
    Resize <: Augmentor.ImageOperation

Description
--------------

Rescales the image to a fixed pre-specified pixel size.

This operation does not take any measures to preserve aspect
ratio of the source image. Instead, the original image will
simply be resized to the given dimensions. This is useful when
one needs a set of images to all be of the exact same size.

Usage
--------------

    Resize(; height=64, width=64)

    Resize(size)

    Resize(size...)

Arguments
--------------

- **`size`** : `NTuple` or `Vararg` of `Int` that denote the
    output size in pixel for each dimension.

See also
--------------

[`CropSize`](@ref), [`augment`](@ref)

Examples
--------------

```julia
using Augmentor
img = testpattern()

augment(img, Resize(30, 40))
```
"""
struct Resize{N} <: ImageOperation
    size::NTuple{N,Int}

    function Resize{N}(size::NTuple{N,Int}) where N
        all(s->s>0, size) || throw(ArgumentError("Specified sizes must be strictly greater than 0. Actual: $size"))
        new{N}(size)
    end
end
Resize(::Tuple{}) = throw(MethodError(Resize, ((),)))
Resize(size::NTuple{N,Int}) where {N} = Resize{N}(size)
Resize(size::Int...) = Resize(size)
Resize(; width=64, height=64) = Resize((height,width))

@inline supports_affineview(::Type{<:Resize}) = true

function toaffinemap(op::Resize{2}, img::AbstractMatrix)
    # emulate behaviour of ImageTransformations.imresize!
    Rin  = CartesianRange(indices(img))
    sf = map(/, op.size, (last(Rin)-first(Rin)+1).I)
    offset = map((io,ir,s)->io - 0.5 - s*(ir-0.5), first(Rin).I, (1, 1), map(inv,sf))
    ttrans = AffineMap(@SMatrix([1. 0.; 0. 1.]), SVector(offset))
    tscale = recenter(@SMatrix([sf[1] 0.; 0. sf[2]]), @SVector([1., 1.]))
    tscale ∘ ttrans
end

function applyeager(op::Resize, img::AbstractArray, param)
    plain_array(imresize(img, op.size))
end

function applylazy(op::Resize, img::AbstractArray, param)
    applyaffineview(op, prepareaffine(img), param)
end

function padrange(range::AbstractUnitRange, pad)
    first(range)-pad:last(range)+pad
end

function applyaffineview(op::Resize{N}, img::AbstractArray{T,N}, param) where {T,N}
    Rin, Rout = CartesianRange(indices(img)), CartesianRange(op.size)
    sf = map(/, (last(Rout)-first(Rout)+1).I, (last(Rin)-first(Rin)+1).I)
    # We have to extrapolate if the image is upscaled,
    # otherwise the original border will only cause a single pixel
    tinv = toaffinemap(op, img, param)
    inds = ImageTransformations.autorange(img, tinv)
    pad_inds = map((s,r)-> s>=1 ? padrange(r,ceil(Int,s/2)) : r, sf, inds)
    wv = invwarpedview(img, tinv, pad_inds)
    # expanding will cause an additional pixel that has to be skipped
    indirect_view(wv, map(s->2:s+1, op.size))
end

function showconstruction(io::IO, op::Resize)
    print(io, typeof(op).name.name, '(', join(map(string, op.size),", "), ')')
end

function Base.show(io::IO, op::Resize{N}) where {N}
    if get(io, :compact, false)
        if N == 2
            print(io, "Resize to $(op.size[1])×$(op.size[2])")
        else
            print(io, "Resize to $(op.size)")
        end
    else
        print(io, typeof(op), "($(op.size))")
    end
end
