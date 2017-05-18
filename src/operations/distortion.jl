immutable ElasticDistortion <: Operation
    gridheight::Int
    gridwidth::Int
    scale::Float64
    sigma::Float64
    iterations::Int
    border::Bool
    normalize::Bool

    function (::Type{ElasticDistortion})(
            gridheight::Integer, gridwidth::Integer,
            scale, sigma, iterations = 1,
            border::Bool = false, normalize::Bool = true)
        (gridwidth > 2 && gridheight > 2) || throw(ArgumentError("gridwidth and gridheight need to be greater than 2"))
        sigma > 0 || throw(ArgumentError("sigma needs to be greater than 0"))
        iterations > 0 || throw(ArgumentError("iterations needs to be greater than 0"))
        new(Int(gridheight), Int(gridwidth), Float64(scale), Float64(sigma), Int(iterations), border, normalize)
    end
end

function ElasticDistortion(
        gridheight::Integer, gridwidth::Integer, scale;
        sigma = 2, iterations = 1,
        border::Bool = false, normalize::Bool = true)
    ElasticDistortion(gridheight, gridwidth, scale, sigma, iterations, border, normalize)::ElasticDistortion
end

function ElasticDistortion(
        gridheight::Integer, gridwidth::Integer;
        scale = .2, sigma = 2, iterations = 1,
        border::Bool = false, normalize::Bool = true)
    ElasticDistortion(gridheight, gridwidth, scale, sigma, iterations, border, normalize)::ElasticDistortion
end

@inline supports_eager{T<:ElasticDistortion}(::Type{T}) = false
@inline supports_lazy{T<:ElasticDistortion}(::Type{T})  = true

function applylazy(op::ElasticDistortion, img)
    field = gaussian_field(op.gridheight, op.gridwidth, op.scale, op.sigma, op.iterations, op.border, op.normalize)
    DistortedView(img, field)
end
