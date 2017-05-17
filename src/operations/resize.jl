immutable Resize{N} <: Operation
    size::NTuple{N,Int}

    function (::Type{Resize{N}}){N}(size::NTuple{N,Int})
        all(s->s>0, size) || throw(ArgumentError("Specified sizes must be strictly greater than 0. Actual: $size"))
        new{N}(size)
    end
end
Resize(::Tuple{}) = throw(MethodError(Resize, ((),)))
Resize(; width=64, height=64) = Resize((height,width))
Resize(size::Vararg{Int}) = Resize(size)
Resize{N}(size::NTuple{N,Int}) = Resize{N}(size)

@inline supports_affine{T<:Resize}(::Type{T}) = true

function toaffine(op::Resize{2}, img::AbstractMatrix)
    # emulate behaviour of ImageTransformations.imresize!
    Rin  = CartesianRange(indices(img))
    sf = map(/, op.size, (last(Rin)-first(Rin)+1).I)
    offset = map((io,ir,s)->io - 0.5 - s*(ir-0.5), first(Rin).I, (1, 1), map(inv,sf))
    ttrans = AffineMap(@SMatrix([1. 0.; 0. 1.]), SVector(offset))
    tscale = recenter(@SMatrix([sf[1] 0.; 0. sf[2]]), @SVector([1., 1.]))
    tscale ∘ ttrans
end

applyeager(op::Resize, img) = plain_array(imresize(img, op.size))

function applylazy(op::Resize, img)
    applyaffine(op, prepareaffine(img))
end

function padrange(range::AbstractUnitRange, pad)
    first(range)-pad:last(range)+pad
end

function applyaffine{T,N}(op::Resize{N}, img::AbstractArray{T,N})
    Rin, Rout = CartesianRange(indices(img)), CartesianRange(op.size)
    sf = map(/, (last(Rout)-first(Rout)+1).I, (last(Rin)-first(Rin)+1).I)
    # We have to extrapolate if the image is upscaled,
    # otherwise the original border will only cause a single pixel
    tinv = toaffine(op, img)
    inds = ImageTransformations.autorange(img, tinv)
    pad_inds = map((s,r)-> s>=1 ? padrange(r,ceil(Int,s/2)) : r, sf, inds)
    wv = invwarpedview(img, tinv, pad_inds)
    # expanding will cause an additional pixel that has to be skipped
    indirect_view(wv, map(s->2:s+1, op.size))
end

function Base.show{N}(io::IO, op::Resize{N})
    if get(io, :compact, false)
        if N == 2
            print(io, "Resize to $(op.size[1])×$(op.size[2])")
        else
            print(io, "Resize to $(op.size)")
        end
    else
        print(io, "$(typeof(op))($(op.size))")
    end
end
