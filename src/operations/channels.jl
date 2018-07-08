"""
    SplitChannels <: Augmentor.Operation

Description
--------------

Splits out the color channels of the given image using the
function `ImageCore.channelview`. This will effectively create a
new array dimension for the colors in the front. In contrast to
`ImageCore.channelview` it will also result in a new dimension
for gray images.

This operation is mainly useful at the end of a pipeline in
combination with [`PermuteDims`](@ref) in order to prepare the
image for the training algorithm, which often requires the color
channels to be separate.

Usage
--------------

    SplitChannels()

See also
--------------

[`PermuteDims`](@ref), [`CombineChannels`](@ref), [`augment`](@ref)

Examples
--------------

```julia-repl
julia> using Augmentor

julia> img = testpattern()
300×400 Array{RGBA{N0f8},2}:
[...]

julia> augment(img, SplitChannels())
4×300×400 Array{N0f8,3}:
[...]

julia> augment(img, SplitChannels() |> PermuteDims(3,2,1))
400×300×4 Array{N0f8,3}:
[...]
```
"""
struct SplitChannels <: Operation end

@inline supports_eager(::Type{SplitChannels}) = false
@inline supports_lazy(::Type{SplitChannels}) = true

function applylazy(op::SplitChannels, img::AbstractArray{<:Colorant}, param)
    plain_indices(channelview(img))
end

function applylazy(op::SplitChannels, img::AbstractArray{<:AbstractGray}, param)
    ns = (1, map(length, indices(img))...)
    reshape(channelview(img), ns)
end

function showconstruction(io::IO, op::SplitChannels)
    print(io, typeof(op).name.name, "()")
end

function Base.show(io::IO, op::SplitChannels)
    if get(io, :compact, false)
        print(io, "Split colorant into its color channels")
    else
        print(io, "Augmentor.")
        showconstruction(io, op)
    end
end

# --------------------------------------------------------------------

"""
    CombineChannels <: Augmentor.Operation

Description
--------------

Combines the first dimension of a given array into a colorant of
type `colortype` using the function `ImageCore.colorview`. The
main difference is that a separate color channel is also expected
for Gray images.

The shape of the input image has to be appropriate for the given
`colortype`, which also means that the separated color channel
has to be the first dimension of the array. See
[`PermuteDims`](@ref) if that is not the case.

Usage
--------------

    CombineChannels(colortype)

Arguments
--------------

- **`colortype`** : The color type of the resulting image. Must
    be a subtype of `ColorTypes.Colorant` and match the color
    channel of the given image.

See also
--------------

[`SplitChannels`](@ref), [`PermuteDims`](@ref), [`augment`](@ref)

Examples
--------------

```julia-repl
julia> using Augmentor, Colors

julia> A = rand(3, 10, 10) # three color channels
3×10×10 Array{Float64,3}:
[...]

julia> augment(A, CombineChannels(RGB))
10×10 Array{RGB{Float64},2}:
[...]

julia> B = rand(1, 10, 10) # singleton color channel
1×10×10 Array{Float64,3}:
[...]

julia> augment(B, CombineChannels(Gray))
10×10 Array{Gray{Float64},2}:
[...]
```
"""
struct CombineChannels{T<:Colorant} <: Operation
    colortype::Type{T}
end

@inline supports_eager(::Type{<:CombineChannels}) = false
@inline supports_lazy(::Type{<:CombineChannels}) = true

function applylazy(op::CombineChannels, img::AbstractArray{<:Number}, param)
    colorview(op.colortype, plain_indices(img))
end

function applylazy(op::CombineChannels{<:AbstractGray}, img::AbstractArray{<:Number}, param)
    length(indices(img,1)) == 1 || throw(ArgumentError("The given image must have a singleton colorchannel in the first dimension in order to combine the channels to a AbstractGray colorant"))
    ns = Base.tail(map(length, indices(img)))
    colorview(op.colortype, reshape(img, ns))
end

function showconstruction(io::IO, op::CombineChannels)
    print(io, typeof(op).name.name, '(')
    _showcolor(io, op.colortype)
    print(io, ')')
end

function Base.show(io::IO, op::CombineChannels)
    if get(io, :compact, false)
        print(io, "Combine color channels into colorant ")
        _showcolor(io, op.colortype)
    else
        print(io, "Augmentor.")
        showconstruction(io, op)
    end
end
