@inline uses_affinemap(::Type{T}) where {T} = supports_affine(T) || supports_affineview(T)

@inline supports_eager(::Type) = true
@inline supports_affine(::Type{<:AffineOperation}) = true
@inline supports_affine(::Type) = false
@inline supports_affineview(::Type{T}) where {T} = supports_affine(T)
@inline supports_permute(::Type) = false
@inline supports_view(::Type) = false
@inline supports_stepview(::Type) = false
@inline supports_lazy(::Type{T}) where {T} = supports_affine(T) || supports_affineview(T) || supports_stepview(T) || supports_view(T) || supports_permute(T)

@inline supports_eager(A)      = supports_eager(typeof(A))
@inline supports_affine(A)     = supports_affine(typeof(A))
@inline supports_affineview(A) = supports_affineview(typeof(A))
@inline supports_permute(A)    = supports_permute(typeof(A))
@inline supports_view(A)       = supports_view(typeof(A))
@inline supports_stepview(A)   = supports_stepview(typeof(A))
@inline supports_lazy(A)       = supports_lazy(typeof(A))

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
prepareaffine(img) = invwarpedview(img, toaffinemap(NoOp(), img), Flat())
prepareaffine(img::AbstractExtrapolation) = invwarpedview(img, toaffinemap(NoOp(), img))
@inline prepareaffine(img::SubArray{T,N,<:InvWarpedView}) where {T,N} = img
@inline prepareaffine(img::InvWarpedView) = img

# currently unused
@inline preparelazy(img) = img

# --------------------------------------------------------------------
# Operation and AffineOperation fallbacks

function applyeager(op::Operation, img)
    plain_array(applylazy(op, img))
end

function applyaffine(op::AffineOperation, img)
    invwarpedview(img, toaffinemap(op, img))
end

function applyaffineview(op::Operation, img)
    wv = applyaffine(op, img)
    direct_view(wv, indices(wv))
end

# Allow affine operations to omit specifying a custom
# "applylazy". On the other hand this also makes sure that a
# custom implementation of "applylazy" is preferred over
# "applylazy_fallback" which by default just calls "applyaffine".
function applylazy(op::AffineOperation, img)
    _applylazy(op, img)
end

# The purpose of having a separate "_applylazy" is to not
# force "applylazy" implementations to specify the type of "img".
function _applylazy(op::AffineOperation, img::InvWarpedView)
    applyaffine(op, img)
end

function _applylazy(op::AffineOperation, img::SubArray{T,N,<:InvWarpedView}) where {T,N}
    applyaffine(op, img)
end

function _applylazy(op::AffineOperation, img)
    applylazy_fallback(op, img)
end

# Defining "applylazy_fallback" instead of "applylazy" will
# make sure that the custom implementation is only used if
# "img" is not already an "InvWarpedView", in which case
# "applyaffine" would be called instead of "applylazy_fallback".
function applylazy_fallback(op::AffineOperation, img)
    applyaffine(op, prepareaffine(img))
end

# --------------------------------------------------------------------
# Since an "AffineMap" is strongly typed, the resulting type of
# "toaffinemap" can be very different from one operation to the
# next. To allow for type-stable stochastic branches (i.e. "Either")
# we need a way to force a common "AffineMap" type using only
# "SArray" internally (i.e. no "RotMatrix" or other special types).

@generated function toaffinemap_common(op::AffineOperation, img::AbstractArray{T,N}) where {T,N}
    quote
        tfm = toaffinemap(op, img)
        AffineMap(SMatrix(tfm.m), SVector(tfm.v))::AffineMap{SArray{Tuple{$N,$N},Float64,$N,$(N*N)},SVector{$N,Float64}}
    end
end

function applyaffine_common(op::AffineOperation, img)
    invwarpedview(img, toaffinemap_common(op, img))
end

function applyaffineview_common(op::Operation, img)
    wv = applyaffine_common(op, img)
    direct_view(wv, indices(wv))
end

# --------------------------------------------------------------------
# Functions to unroll sequences of Operation. These are called by
# the pipeline logic to prefer specific behaviour.

# "applyaffine" or "applyaffineview" is accepted
@inline @generated function unroll_applyaffine(op::Operation, img)
    if supports_affine(op)
        :(applyaffine(op, img))
    elseif supports_affineview(op)
        :(applyaffineview(op, img))
    else
        :(throw(MethodError(unroll_applyaffine, (op, img))))
    end
end

@inline unroll_applylazy(op::Operation, img) = applylazy(op, img)

# Recursively unroll the sequentially applied operations.
# This will result in a function that is equivalent to hardcoded
# chaining of operations.
for KIND in (:affine, :lazy)
    FUN = Symbol(:unroll_apply, KIND)
    PRE = Symbol(:prepare, KIND)
    @eval begin
        function ($FUN)(operations::NTuple{N,Operation}, img) where N
            ($FUN)(first(operations), Base.tail(operations), ($PRE)(img))
        end

        @inline function ($FUN)(head::Operation, tail::Tuple, img)
            ($FUN)(first(tail), Base.tail(tail), ($FUN)(head, img))
        end

        @inline function ($FUN)(head::Operation, tail::Tuple{}, img)
            ($FUN)(head, img)
        end
    end
end
