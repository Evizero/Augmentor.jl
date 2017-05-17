immutable Zoom{N,T<:AbstractVector} <: Operation
    factors::NTuple{N,T}

    function (::Type{Zoom{N}}){N,T<:AbstractVector}(factors::NTuple{N,T})
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
Zoom{N}(factors::NTuple{N,Any}) = Zoom(map(_vectorize, factors))
Zoom{N}(factors::NTuple{N,Range}) = Zoom{N}(promote(factors...))
function Zoom{N}(factors::NTuple{N,AbstractVector})
    Zoom{N}(map(Vector{Float64}, factors))
end
function (::Type{Zoom{N}}){N}(factors::NTuple{N,Any})
    Zoom(map(_vectorize, factors))
end

@inline supports_affine{T<:Zoom}(::Type{T}) = true
@inline supports_eager{T<:Zoom}(::Type{T}) = false

function toaffine(op::Zoom{2}, img::AbstractMatrix)
    idx = rand(1:length(op.factors[1]))
    @inbounds tfm = recenter(@SMatrix([Float64(op.factors[1][idx]) 0.; 0. Float64(op.factors[2][idx])]), center(img))
    tfm
end

function applyeager(op::Zoom, img)
    plain_array(applylazy(op, img))
end

function applylazy(op::Zoom, img)
    applyaffine(op, prepareaffine(img))
end

function applyaffine{T,N}(op::Zoom{N}, img::AbstractArray{T,N})
    invwarpedview(img, toaffine(op, img), indices(img))
end

function applyaffine{T,N,W<:InvWarpedView}(op::Zoom{N}, v::SubArray{T,N,W})
    tinv = toaffine(op, v)
    img = parent(v)
    nidx = ImageTransformations.autorange(img, tinv)
    wv = InvWarpedView(img, tinv, map(unionrange, nidx, indices(img)))
    view(wv, v.indexes...)
end

function Base.show{N}(io::IO, op::Zoom{N})
    if get(io, :compact, false)
        str = join(map(t->join(_round(t,2),"×"), collect(zip(op.factors...))), ", ")
        if length(op.factors[1]) == 1
            print(io, "Zoom by $(str)")
        else
            print(io, "Zoom by I ∈ {$(str)}")
        end
    else
        fct = length(op.factors[1]) == 1 ? map(first,op.factors) : op.factors
        print(io, "Augmentor.Zoom{$N}($(fct))")
    end
end
