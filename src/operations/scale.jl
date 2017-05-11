immutable Scale{N,T<:AbstractVector} <: AffineOperation
    factors::NTuple{N,T}

    function (::Type{Scale{N}}){N,T<:AbstractVector}(factors::NTuple{N,T})
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
Scale{N}(factors::NTuple{N,Any}) = Scale(map(_vectorize, factors))
Scale{N}(factors::NTuple{N,Range}) = Scale{N}(promote(factors...))
function Scale{N}(factors::NTuple{N,AbstractVector})
    Scale{N}(map(Vector{Float64}, factors))
end
function (::Type{Scale{N}}){N}(factors::NTuple{N,Any})
    Scale(map(_vectorize, factors))
end

Base.@pure supports_eager{T<:Scale}(::Type{T}) = false

function toaffine(op::Scale{2}, img::AbstractMatrix)
    idx = rand(1:length(op.factors[1]))
    @inbounds tfm = recenter(@SMatrix([Float64(op.factors[1][idx]) 0.; 0. Float64(op.factors[2][idx])]), @SVector([1.,1.]))
    tfm
end

function Base.show{N}(io::IO, op::Scale{N})
    if get(io, :compact, false)
        str = join(map(t->join(t,"×"), collect(zip(op.factors...))), ", ")
        if length(op.factors[1]) == 1
            print(io, "Scale by $(str)")
        else
            print(io, "Scale by I ∈ {$(str)}")
        end
    else
        fct = length(op.factors[1]) == 1 ? map(first,op.factors) : op.factors
        print(io, "Augmentor.Scale{$N}($(fct))")
    end
end
