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
        sigma = 2, iter = 1,
        border::Bool = false, norm::Bool = true)
    ElasticDistortion(gridheight, gridwidth, scale, sigma, iter, border, norm)::ElasticDistortion
end

function ElasticDistortion(
        gridheight::Integer, gridwidth::Integer = gridheight;
        scale = .2, sigma = 2, iter = 1,
        border::Bool = false, norm::Bool = true)
    ElasticDistortion(gridheight, gridwidth, scale, sigma, iter, border, norm)::ElasticDistortion
end

@inline supports_eager{T<:ElasticDistortion}(::Type{T}) = false
@inline supports_lazy{T<:ElasticDistortion}(::Type{T})  = true

function applylazy(op::ElasticDistortion, img)
    field = gaussian_field(op.gridheight, op.gridwidth, op.scale, op.sigma, op.iterations, op.border, op.normalize)
    DistortedView(img, field)
end

function showconstruction(io::IO, op::ElasticDistortion)
    str_size = "$(op.gridheight), $(op.gridwidth)"
    str_scale  = op.scale      == 0.2   ? "" : "scale=$(op.scale)"
    str_sigma  = op.sigma      == 2     ? "" : "sigma=$(op.sigma)"
    str_iter   = op.iterations == 1     ? "" : "iter=$(op.iterations)"
    str_border = op.border     == false ? "" : "border=$(op.border)"
    str_norm   = op.normalize  == true  ? "" : "norm=$(op.normalize)"
    str_all = filter(str->str!="", [str_size, str_scale, str_sigma, str_iter, str_border, str_norm])
    print(io, typeof(op).name.name, '(', join(str_all, ", "), ')')
end

function Base.show(io::IO, op::ElasticDistortion)
    if get(io, :compact, false)

        str_sigma  = op.sigma      == 2 ? "" : "(σ=$(op.sigma)) "
        str_iter   = op.iterations == 1 ? "" : "$(op.iterations)-times "
        str_norm   = op.normalize  == true ? "and normalized " : ""
        str_border = op.border     == false ? " with pinned border" : ""

        print(io, "Distort using a $(str_iter)smoothed $(str_norm)$(op.gridheight)×$(op.gridwidth) grid$(str_border)")
    else
        print(io, "Augmentor.")
        showconstruction(io, op)
    end
end
