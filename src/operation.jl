@inline isaffine{T<:AffineOperation}(::Type{T}) = true
@inline isaffine(::Type) = false

@inline supports_eager(::Type) = true
@inline supports_affine{T}(::Type{T}) = isaffine(T)
@inline supports_permute(::Type) = false
@inline supports_view(::Type) = false
@inline supports_stepview(::Type) = false
@inline supports_lazy{T}(::Type{T}) = supports_affine(T) || supports_stepview(T) || supports_view(T) || supports_permute(T)

@inline isaffine(A) = isaffine(typeof(A))
@inline supports_eager(A)    = supports_eager(typeof(A))
@inline supports_affine(A)   = supports_affine(typeof(A))
@inline supports_permute(A)  = supports_permute(typeof(A))
@inline supports_view(A)     = supports_view(typeof(A))
@inline supports_stepview(A) = supports_stepview(typeof(A))
@inline supports_lazy(A)     = supports_lazy(typeof(A))

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
prepareaffine(img) = invwarpedview(img, toaffine(NoOp(), img), Flat())
prepareaffine(img::AbstractExtrapolation) = invwarpedview(img, toaffine(NoOp(), img))
@inline prepareaffine{T,N,A<:InvWarpedView}(img::SubArray{T,N,A}) = img
@inline prepareaffine(img::InvWarpedView) = img

# currently unused
@inline prepareview(img) = img
@inline preparestepview(img) = img
@inline preparepermute(img) = img
@inline preparelazy(img) = img

# --------------------------------------------------------------------
# AffineOperation fallbacks

function applyeager(op::AffineOperation, img)
    plain_array(applylazy(op, img))
end

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

for KIND in (:affine, :lazy) # :permute, :view, :stepview)
    APP = Symbol(:apply, KIND)
    PRE = Symbol(:prepare, KIND)
    @eval begin
        function ($APP)(pipeline::Tuple, img)
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
