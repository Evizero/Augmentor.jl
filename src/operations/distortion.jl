immutable SmoothedDistortion <: Operation
    gridwidth::Int
    gridheight::Int
    scale::Float64
    sigma::Float64
    iterations::Int
    static_border::Bool
    normalize::Bool
end

function SmoothedDistortion(gridwidth::Integer, gridheight::Integer; scale = .2, sigma = 2, iterations = 1, static_border::Bool = true, normalize::Bool = true)
    (gridwidth > 2 && gridheight > 2) || throw(ArgumentError("gridwidth and gridheight need to be greater than 2"))
    sigma > 0 || throw(ArgumentError("sigma needs to be greater than 0"))
    iterations > 0 || throw(ArgumentError("iterations needs to be greater than 0"))
    SmoothedDistortion(Int(gridwidth), Int(gridheight), Float64(scale), Float64(sigma), Int(iterations), static_border, normalize)
end

@inline supports_eager{T<:SmoothedDistortion}(::Type{T}) = false
@inline supports_lazy{T<:SmoothedDistortion}(::Type{T})  = true

applyeager(op::SmoothedDistortion, img) = plain_array(applylazy(op, img))

function applylazy(op::SmoothedDistortion, img)
    field = gaussian_field(op.gridwidth, op.gridheight, op.scale, op.sigma, op.iterations, op.static_border, op.normalize)
    DistortedView(img, field)
end
