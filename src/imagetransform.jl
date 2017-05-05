@compat abstract type ImageTransform end
@compat abstract type AffineImageTransform <: ImageTransform end
@compat const Pipeline{N} = NTuple{N,ImageTransform}

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

function Base.show{N}(io::IO, pipeline::Pipeline{N})
    n = length(pipeline)
    if get(io, :compact, false)
        print(io, "(")
        for (i, tfm) in enumerate(pipeline)
            Base.showcompact(io, tfm)
            i < n && print(io, ", ")
        end
        print(io, ")")
    else
        k = length("$(length(pipeline))")
        print(io, "$n-step Augmentor.Pipeline:")
        for (i, tfm) in enumerate(pipeline)
            println(io)
            print(io, lpad("$i", k+1, " "), ".) ")
            Base.showcompact(io, tfm)
        end
    end
end
