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
plain_array(m::Mask) = Mask(plain_array(unwrap(m)))
