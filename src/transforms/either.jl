immutable Either{N,T<:Tuple} <: ImageTransform
    transforms::T
    chances::SVector{N,Float64}
    cum_chances::SVector{N,Float64}

    function (::Type{Either}){N,T}(transforms::NTuple{N,ImageTransform}, chances::SVector{N,T})
        length(transforms) > 0 || throw(ArgumentError("number of specified image transformations need to be greater than 0"))
        sum_chances = sum(chances)
        @assert sum_chances > 0.
        norm_chances = map(x -> Float64(x/sum_chances), chances)
        cum_chances = SVector(cumsum(norm_chances))
        new{N,typeof(transforms)}(transforms, norm_chances, cum_chances)
    end
end

function Either{N}(transforms::NTuple{N,ImageTransform}, chances::NTuple{N,Real} = map(tfm -> 1/length(transforms), transforms))
    Either(transforms, SVector{N}(chances))
end

function Either{N}(transforms::Vararg{ImageTransform,N}; chances = map(tfm -> 1/length(transforms), transforms))
    Either(transforms, SVector{N}(map(Float64,chances)))
end

function Either{N}(transforms::Vararg{Pair,N})
    Either(map(last, transforms), map(first, transforms))
end

function Either(tfm::ImageTransform, p::Real = .5)
    0 <= p <= 1. || throw(ArgumentError("The propability \"p\" has to be in the interval [0, 1]"))
    p1 = Float64(p)
    p2 = 1 - p1
    Either((tfm, NoOp()), (p1, p2))
end

# "Either" is only lazy if all its elements are affine
Base.@pure islazy{N,T}(::Type{Either{N,T}}) = all(map(isaffine, T.types))
Base.@pure isaffine{N,T}(::Type{Either{N,T}}) = all(map(isaffine, T.types))

for FUN in (:toaffine, :applylazy, :applyeager)
    @eval function ($FUN)(tfm::Either, img)
        p = rand()
        for (i, p_i) in enumerate(tfm.cum_chances)
            if p <= p_i
                return ($FUN)(tfm.transforms[i], img)
            end
        end
        ($FUN)(tfm.transforms[end], img)
    end
end

function Base.show(io::IO, tfm::Either)
    if get(io, :compact, false)
        print(io, "Either:")
        for (op_i, p_i) in zip(tfm.transforms, tfm.chances)
            print(io, " (", round(Int, p_i*100), "%) ")
            Base.showcompact(io, op_i)
            print(io, '.')
        end
    else
        print(io, "Augmentor.Either (1 out of ", length(tfm.transforms), " transformation(s)):")
        for (op_i, p_i) in zip(tfm.transforms, tfm.chances)
            println(io)
            print(io, "  - ", round(p_i*100, 1), "% chance to: ")
            Base.showcompact(io, op_i)
        end
    end
end
