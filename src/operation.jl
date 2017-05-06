@compat abstract type Operation end
@compat abstract type AffineOperation <: Operation end

# --------------------------------------------------------------------

@compat const Pipeline{N} = NTuple{N,Operation}

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

# --------------------------------------------------------------------

Base.@pure isaffine{T<:AffineOperation}(::Type{T}) = true
Base.@pure isaffine(::Type) = false

Base.@pure supports_affine{T}(::Type{T}) = isaffine(T)
Base.@pure supports_permute(::Type) = false
Base.@pure supports_view(::Type) = false
Base.@pure supports_stepview(::Type) = false
Base.@pure supports_lazy{T}(::Type{T}) = supports_affine(T) || supports_stepview(T) || supports_view(T) || supports_permute(T)

Base.@pure isaffine(A) = isaffine(typeof(A))
Base.@pure supports_affine(A) = supports_affine(typeof(A))
Base.@pure supports_permute(A) = supports_permute(typeof(A))
Base.@pure supports_view(A) = supports_view(typeof(A))
Base.@pure supports_stepview(A) = supports_stepview(typeof(A))
Base.@pure supports_lazy(A) = supports_lazy(typeof(A))

# --------------------------------------------------------------------

function prepareaffine(op, img)
    ImageTransformations.box_extrapolation(img, Flat())
end

@inline prepareaffine{T,N,A<:InvWarpedView}(op, img::SubArray{T,N,A}) = img
@inline prepareaffine(op, img::InvWarpedView) = img
@inline prepareaffine(op, img::AbstractExtrapolation) = img

@inline prepareview(op, img) = img
@inline preparestepview(op, img) = img
@inline preparepermute(op, img) = img
@inline preparelazy(op, img) = img

# --------------------------------------------------------------------

function applyaffine(op::AffineOperation, img)
    invwarpedview(img, toaffine(op, img))
end

function applylazy(op::AffineOperation, img)
    applyaffine(op, prepareaffine(op, img))
end

# --------------------------------------------------------------------

for KIND in (:affine, :permute, :view, :stepview, :lazy)
    FUN = Symbol(:apply, KIND)
    PRE = Symbol(:prepare, KIND)
    @eval begin
        function ($FUN){N}(pipeline::Pipeline{N}, img)
            ($FUN)(first(pipeline), Base.tail(pipeline), ($PRE)(first(pipeline), img))
        end

        @inline function ($FUN)(head::Operation, tail::Tuple, img)
            ($FUN)(first(tail), Base.tail(tail), ($FUN)(head, img))
        end

        @inline function ($FUN)(head::Operation, tail::Tuple{}, img)
            ($FUN)(head, img)
        end
    end
end
