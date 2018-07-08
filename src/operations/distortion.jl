const ED_DEFAULT_SCALE  = 0.2
const ED_DEFAULT_SIGMA  = 2
const ED_DEFAULT_ITER   = 1
const ED_DEFAULT_BORDER = false
const ED_DEFAULT_NORM   = true

@doc """
    ElasticDistortion <: Augmentor.ImageOperation

Description
--------------

Distorts the given image using a randomly (uniform) generated
vector field of the given grid size. This field will be stretched
over the given image when applied, which in turn will morph the
original image into a new image using a linear interpolation of
both the image and the vector field.

In contrast to [`RandomDistortion`], the resulting vector
field is also smoothed using a Gaussian filter with of parameter
`sigma`. This will result in a less chaotic vector field and thus
resemble a more natural distortion.

Usage
--------------

    ElasticDistortion(gridheight, gridwidth, scale, sigma, [iter=$ED_DEFAULT_ITER], [border=$ED_DEFAULT_BORDER], [norm=$ED_DEFAULT_NORM])

    ElasticDistortion(gridheight, gridwidth, scale; [sigma=$ED_DEFAULT_SIGMA], [iter=$ED_DEFAULT_ITER], [border=$ED_DEFAULT_BORDER], [norm=$ED_DEFAULT_NORM])

    ElasticDistortion(gridheight, [gridwidth]; [scale=$ED_DEFAULT_SCALE], [sigma=$ED_DEFAULT_SIGMA], [iter=$ED_DEFAULT_ITER], [border=$ED_DEFAULT_BORDER], [norm=$ED_DEFAULT_NORM])

Arguments
--------------

- **`gridheight`** : The grid height of the displacement vector
    field. This effectively specifies the number of vertices
    along the Y dimension used as landmarks, where all the
    positions between the grid points are interpolated.

- **`gridwidth`** : The grid width of the displacement vector
    field. This effectively specifies the number of vertices
    along the Y dimension used as landmarks, where all the
    positions between the grid points are interpolated.

- **`scale`** : Optional. The scaling factor applied to all
    displacement vectors in the field. This effectively defines
    the "strength" of the deformation. There is no theoretical
    upper limit to this factor, but a value somewhere between
    `0.01` and `1.0` seem to be the most reasonable choices.
    Default to `$ED_DEFAULT_SCALE`.

- **`sigma`** : Optional. Sigma parameter of the Gaussian filter.
    This parameter effectively controls the strength of the
    smoothing. Defaults to `$ED_DEFAULT_SIGMA`.

- **`iter`** : Optional. The number of times the smoothing
    operation is applied to the displacement vector field. This
    is especially useful if `border = false` because the border
    will be reset to zero after each pass. Thus the displacement
    is a little less aggressive towards the borders of the image
    than it is towards its center. Defaults to
    `$ED_DEFAULT_ITER`.

- **`border`** : Optional. Specifies if the borders should be
    distorted as well. If `false`, the borders of the image will
    be preserved. This effectively pins the outermost vertices on
    their original position and the operation thus only distorts
    the inner content of the image. Defaults to
    `$ED_DEFAULT_BORDER`.

- **`norm`** : Optional. If `true`, the displacement vectors of
    the field will be normalized by the norm of the field. This
    will have the effect that the `scale` factor should be more
    or less independent of the grid size. Defaults to
    `$ED_DEFAULT_NORM`.

See also
--------------

[`augment`](@ref)

Examples
--------------

```julia
using Augmentor
img = testpattern()

# distort with pinned borders
augment(img, ElasticDistortion(15, 15; scale = 0.1))

# distort everything more smoothly.
augment(img, ElasticDistortion(10, 10; sigma = 4, iter=3, border=true))
```
""" ->
struct ElasticDistortion <: ImageOperation
    gridheight::Int
    gridwidth::Int
    scale::Float64
    sigma::Float64
    iterations::Int
    border::Bool
    normalize::Bool

    function ElasticDistortion(
            gridheight::Integer, gridwidth::Integer,
            scale, sigma, iterations = ED_DEFAULT_ITER,
            border::Bool = ED_DEFAULT_BORDER, normalize::Bool = ED_DEFAULT_NORM)
        (gridwidth > 2 && gridheight > 2) || throw(ArgumentError("gridwidth and gridheight need to be greater than 2"))
        sigma > 0 || throw(ArgumentError("sigma needs to be greater than 0"))
        iterations > 0 || throw(ArgumentError("iterations needs to be greater than 0"))
        new(Int(gridheight), Int(gridwidth), Float64(scale), Float64(sigma), Int(iterations), border, normalize)
    end
end

function ElasticDistortion(
        gridheight::Integer, gridwidth::Integer, scale;
        sigma = ED_DEFAULT_SIGMA, iter = ED_DEFAULT_ITER,
        border::Bool = ED_DEFAULT_BORDER, norm::Bool = ED_DEFAULT_NORM)
    ElasticDistortion(gridheight, gridwidth, scale, sigma, iter, border, norm)::ElasticDistortion
end

function ElasticDistortion(
        gridheight::Integer, gridwidth::Integer = gridheight;
        scale = ED_DEFAULT_SCALE,
        sigma = ED_DEFAULT_SIGMA, iter = ED_DEFAULT_ITER,
        border::Bool = ED_DEFAULT_BORDER, norm::Bool = ED_DEFAULT_NORM)
    ElasticDistortion(gridheight, gridwidth, scale, sigma, iter, border, norm)::ElasticDistortion
end

@inline supports_eager(::Type{<:ElasticDistortion}) = false
@inline supports_lazy(::Type{<:ElasticDistortion})  = true

function randparam(op::ElasticDistortion, img)
    gaussian_field(op.gridheight, op.gridwidth, op.scale, op.sigma, op.iterations, op.border, op.normalize)
end

function applylazy(op::ElasticDistortion, img::AbstractArray, field)
    DistortedView(img, field)
end

function showconstruction(io::IO, op::ElasticDistortion)
    str_size   = join(map(string,(op.gridheight,op.gridwidth)), ", ")
    str_scale  = op.scale      == ED_DEFAULT_SCALE  ? "" : "scale=$(op.scale)"
    str_sigma  = op.sigma      == ED_DEFAULT_SIGMA  ? "" : "sigma=$(op.sigma)"
    str_iter   = op.iterations == ED_DEFAULT_ITER   ? "" : "iter=$(op.iterations)"
    str_border = op.border     == ED_DEFAULT_BORDER ? "" : "border=$(op.border)"
    str_norm   = op.normalize  == ED_DEFAULT_NORM   ? "" : "norm=$(op.normalize)"
    str_all = filter(str->str!="", [str_size, str_scale, str_sigma, str_iter, str_border, str_norm])
    print(io, typeof(op).name.name, '(', join(str_all, ", "), ')')
end

function Base.show(io::IO, op::ElasticDistortion)
    if get(io, :compact, false)
        str_size   = join(map(string,(op.gridheight,op.gridwidth)), "×")
        str_sigma  = op.sigma      == ED_DEFAULT_SIGMA ? "" : "(σ=$(op.sigma)) "
        str_iter   = op.iterations == 1     ? "" : "$(op.iterations)-times "
        str_norm   = op.normalize  == true  ? "and normalized " : ""
        str_border = op.border     == false ? " with pinned border" : ""
        print(io, "Distort using a $(str_iter)smoothed $(str_norm)$(str_size) grid$(str_border)")
    else
        print(io, "Augmentor.")
        showconstruction(io, op)
    end
end
