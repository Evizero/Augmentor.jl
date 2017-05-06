@compat abstract type Operation end
@compat abstract type AffineOperation <: Operation end
@compat const Pipeline{N} = NTuple{N,Operation}

@inline islazy{T}(::Type{T}) = isaffine(T)
@inline isaffine{T<:AffineOperation}(::Type{T}) = true
@inline isaffine(::Type) = false

islazy(A) = islazy(typeof(A))
isaffine(A) = isaffine(typeof(A))

# --------------------------------------------------------------------

function applylazy(op::AffineOperation, img::AbstractArray)
    etp = ImageTransformations.box_extrapolation(img, Flat())
    applylazy(op, etp)
end

function applylazy(op::AffineOperation, img::AbstractExtrapolation)
    invwarpedview(img, toaffine(op, img))
end

function applylazy{N}(pipeline::Pipeline{N}, img)
    applylazy(first(pipeline), Base.tail(pipeline), img)
end

@inline function applylazy(head::Operation, tail::Tuple, img)
    applylazy(first(tail), Base.tail(tail), applylazy(head, img))
end

@inline function applylazy(head::Operation, tail::Tuple{}, img)
    applylazy(head, img)
end

# --------------------------------------------------------------------

function Base.show(io::IO, pipeline::Pipeline{0})
    print(io, "()")
end

function Base.show{N}(io::IO, pipeline::Pipeline{N})
    n = length(pipeline)
    if get(io, :compact, false)
        print(io, "(")
        for (i, op) in enumerate(pipeline)
            Base.showcompact(io, op)
            i < n && print(io, ", ")
        end
        print(io, ")")
    else
        k = length("$(length(pipeline))")
        print(io, "$n-step Augmentor.Pipeline:")
        for (i, op) in enumerate(pipeline)
            println(io)
            print(io, lpad("$i", k+1, " "), ".) ")
            Base.showcompact(io, op)
        end
    end
end
