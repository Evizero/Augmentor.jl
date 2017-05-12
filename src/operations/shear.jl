immutable ShearX{T<:AbstractVector} <: AffineOperation
    degree::T

    function (::Type{ShearX}){T<:Real}(degree::AbstractVector{T})
        length(degree) > 0 || throw(ArgumentError("The number of different angles passed to \"ShearX(...)\" must be non-zero"))
        (minimum(degree) >= -70 && maximum(degree) <= 70) || throw(ArgumentError("The specified shearing angle(s) must be in the interval [-70, 70]"))
        new{typeof(degree)}(degree)
    end
end
ShearX(degree::Real) = ShearX(degree:degree)

Base.@pure supports_eager{T<:ShearX}(::Type{T}) = false

function toaffine(op::ShearX, img::AbstractMatrix)
    angle = deg2rad(Float64(rand(op.degree)))
    recenter(@SMatrix([1. 0.; tan(-angle) 1.]), center(img))
end

function Base.show(io::IO, op::ShearX)
    if get(io, :compact, false)
        if length(op.degree) == 1
            print(io, "ShearX ", first(op.degree), " degree")
        else
            print(io, "ShearX by ϕ ∈ ", op.degree, " degree")
        end
    else
        if length(op.degree) == 1
            print(io, "Augmentor.ShearX($(first(op.degree)))")
        else
            print(io, "Augmentor.ShearX($(op.degree))")
        end
    end
end

# --------------------------------------------------------------------

immutable ShearY{T<:AbstractVector} <: AffineOperation
    degree::T

    function (::Type{ShearY}){T<:Real}(degree::AbstractVector{T})
        length(degree) > 0 || throw(ArgumentError("The number of different angles passed to \"ShearY(...)\" must be non-zero"))
        (minimum(degree) >= -70 && maximum(degree) <= 70) || throw(ArgumentError("The specified shearing angle(s) must be in the interval [-70, 70]"))
        new{typeof(degree)}(degree)
    end
end
ShearY(degree::Real) = ShearY(degree:degree)

Base.@pure supports_eager{T<:ShearY}(::Type{T}) = false

function toaffine(op::ShearY, img::AbstractMatrix)
    angle = deg2rad(Float64(rand(op.degree)))
    recenter(@SMatrix([1. tan(-angle); 0. 1.]), center(img))
end

function Base.show(io::IO, op::ShearY)
    if get(io, :compact, false)
        if length(op.degree) == 1
            print(io, "ShearY ", first(op.degree), " degree")
        else
            print(io, "ShearY by ψ ∈ ", op.degree, " degree")
        end
    else
        if length(op.degree) == 1
            print(io, "Augmentor.ShearY($(first(op.degree)))")
        else
            print(io, "Augmentor.ShearY($(op.degree))")
        end
    end
end
