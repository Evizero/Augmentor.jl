"""
A SemanticWrapper determines the semantics of data that it wraps.
Any subtype needs to implement function `unwrap(wrapper)` that returns the
wrapped data.
"""
abstract type SemanticWrapper end

"""
Mask wraps a segmentation mask.
"""
struct Mask{T<:AbstractArray} <: SemanticWrapper
    img::T

    function Mask(img::T) where {T<:AbstractArray}
        new{T}(img)
    end
end

unwrap(m::Mask) = m.img

"""
    shouldapply(op, wrapper)
    shouldapply(typeof(op), typeof(wrapper))

Determines if operation `op` should be applied to semantic wrapper `wrapper`.
"""
shouldapply(op::Operation, what::SemanticWrapper) = shouldapply(typeof(op), typeof(what))
shouldapply(::Type{<:ImageOperation}, ::Type{<:SemanticWrapper}) = Val(true)
shouldapply(::Type{<:ColorOperation}, ::Type{<:Mask})            = Val(false)
# By default any operation is applicable to any semantic wrapper. Add new
# methods to this function to define exceptions.

# Allows doing `unwrap.(augment(img, Mask(img2), pl))`
unwrap(A::AbstractArray) = A
