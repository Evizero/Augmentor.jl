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
        print(io, '(')
        for (i, op) in enumerate(pipeline)
            Base.showcompact(io, op)
            i < n && print(io, ", ")
        end
        print(io, ')')
    else
        k = length("$(length(pipeline))")
        print(io, "$n-step Augmentor.Pipeline:")
        for (i, op) in enumerate(pipeline)
            println(io)
            print(io, lpad(string(i), k+1, " "), ".) ")
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

"""
    prepareaffine(img)

Make sure `img` is either a `InvWarpedView` or a `SubArray` of
one. If that is already the case, `img` will be returned as is.
Otherwise `invwarpedview` will be called using a `Flat()`
extrapolation scheme.

Doing this will tell subsequent operations that they should also
participate as affine operations (i.e. use `AffineMap` if they
can).
"""
function prepareaffine(img)
    invwarpedview(img, toaffine(NoOp(), img), Flat())
end

@inline prepareaffine{T,N,A<:InvWarpedView}(img::SubArray{T,N,A}) = img
@inline prepareaffine(img::InvWarpedView) = img
@inline prepareaffine(img::AbstractExtrapolation) = img

# currently unused
@inline prepareview(img) = img
@inline preparestepview(img) = img
@inline preparepermute(img) = img
@inline preparelazy(img) = img

# --------------------------------------------------------------------
# AffineOperation fallbacks

function applyaffine(op::AffineOperation, img)
    invwarpedview(img, toaffine(op, img))
end

function applylazy(op::AffineOperation, img)
    _applylazy(op, img)
end

function _applylazy(op::AffineOperation, img::InvWarpedView)
    applyaffine(op, img)
end

function _applylazy{T,N,IT<:InvWarpedView}(op::AffineOperation, img::SubArray{T,N,IT})
    applyaffine(op, img)
end

function _applylazy(op::AffineOperation, img)
    applylazy_fallback(op, img)
end

function applylazy_fallback(op::AffineOperation, img)
    applyaffine(op, prepareaffine(img))
end

# --------------------------------------------------------------------

for KIND in (:affine, :permute, :view, :stepview, :lazy)
    APP = Symbol(:apply, KIND)
    PRE = Symbol(:prepare, KIND)
    @eval begin
        function ($APP)(pipeline::Pipeline, img)
            ($APP)(first(pipeline), Base.tail(pipeline), ($PRE)(img))
        end

        @inline function ($APP)(head::Operation, tail::Tuple, img)
            ($APP)(first(tail), Base.tail(tail), ($APP)(head, img))
        end

        @inline function ($APP)(head::Operation, tail::Tuple{}, img)
            ($APP)(head, img)
        end
    end
end
