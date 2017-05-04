@compat abstract type ImageTransform end
@compat abstract type AffineImageTransform <: ImageTransform end

@inline islazy{T}(::Type{T}) = isaffine(T)
@inline isaffine{T<:AffineImageTransform}(::Type{T}) = true
@inline isaffine(::Type) = false

# --------------------------------------------------------------------

function applylazy(tfm::AffineImageTransform, img)
    invwarpedview(img, toaffine(tfm, img))
end

function applylazy{N}(tfms::NTuple{N,ImageTransform}, img)
    applylazy(first(tfms), Base.tail(tfms), img)
end

@inline function applylazy(head::ImageTransform, tail::Tuple, img)
    applylazy(first(tail), Base.tail(tail), applylazy(head, img))
end

@inline function applylazy(head::ImageTransform, tail::Tuple{}, img)
    applylazy(head, img)
end

# --------------------------------------------------------------------

immutable NoOp <: AffineImageTransform end
toaffine(::NoOp, img) = AffineMap(@SMatrix([1. 0; 0 1.]), @SVector([0.,0.]))
applyeager(::NoOp, img) = img

# --------------------------------------------------------------------

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
