"""
    SplitChannels <: Augmentor.Operation

Description
--------------

Splits out the color channels of the given image using the
function `ImageCore.channelview`. This will effectively create a
new array dimension for the colors in the front. In contrast to
`ImageCore.channelview` it will also result in a new dimension
for Gray images.

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

```julia
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

applylazy(op::SplitChannels, img::AbstractArray{<:Colorant}) = channelview(img)
function applylazy(op::SplitChannels, img::AbstractArray{<:AbstractGray})
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

```julia
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

function applylazy(op::CombineChannels, img::AbstractArray{<:Number})
    colorview(op.colortype, img)
end

function applylazy(op::CombineChannels{<:AbstractGray}, img::AbstractArray{<:Number})
    length(indices(img,1)) == 1 || throw(ArgumentError("The given image must have a singleton colorchannel in the first dimension in order to combine the channels to a AbstractGray colorant"))
    ns = Base.tail(map(length, indices(img)))
    colorview(op.colortype, reshape(img, ns))
end

function showconstruction(io::IO, op::CombineChannels)
    print(io, typeof(op).name.name, '(')
    ImageCore.showcoloranttype(io, op.colortype)
    print(io, ')')
end

function Base.show(io::IO, op::CombineChannels)
    if get(io, :compact, false)
        print(io, "Combine color channels into colorant ")
        ImageCore.showcoloranttype(io, op.colortype)
    else
        print(io, "Augmentor.")
        showconstruction(io, op)
    end
end

# --------------------------------------------------------------------

"""
    PermuteDims <: Augmentor.Operation

Description
--------------

Permute the dimensions of the given array with the predefined
permutation `perm`. This operation is particularly useful if the
order of the dimensions needs to be different than the default
julian layout.

Augmentor expects the given images to be in vertical-major layout
for which the colors are encoded in the element type itself. Many
deep learning frameworks however require their input in a
different order. For example it is not untypical that the color
channels are expected to be encoded in the third dimension.

Usage
--------------

    PermuteDims(perm)

    PermuteDims(perm...)

Arguments
--------------

- **`perm`** : The concrete dimension permutation that should be
    used. Has to be specified as a `Vararg{Int}` or as a `NTuple`
    of `Int`. The length of `perm` has to match the number of
    dimensions of the expected input image to that operation.

See also
--------------

[`SplitChannels`](@ref), [`CombineChannels`](@ref), [`augment`](@ref)

Examples
--------------

```julia
julia> using Augmentor, Colors

julia> A = rand(10, 5, 3) # width=10, height=5, and 3 color channels
10×5×3 Array{Float64,3}:
[...]

julia> img = augment(A, PermuteDims(3,2,1) |> CombineChannels(RGB))
5×10 Array{RGB{Float64},2}:
[...]

julia> img2 = testpattern()
300×400 Array{RGBA{N0f8},2}:
[...]

julia> B = augment(img2, SplitChannels() |> PermuteDims(3,2,1))
400×300×4 Array{N0f8,3}:
[...]
```
"""
struct PermuteDims{N,perm,iperm} <: Operation end
PermuteDims() = throw(MethodError(PermuteDims, ()))
PermuteDims(perm::Tuple{}) = throw(MethodError(PermuteDims, (perm,)))
PermuteDims(perm::NTuple{N,Int}) where {N} = PermuteDims{N,perm,invperm(perm)}()
PermuteDims(perm::Vararg{Int,N}) where {N} = PermuteDims{N,perm,invperm(perm)}()

@inline supports_eager(::Type{<:PermuteDims}) = true
@inline supports_lazy(::Type{<:PermuteDims}) = true

function applyeager(op::PermuteDims{N,perm}, img::AbstractArray{T,N}) where {T,N,perm}
    permutedims(img, perm)
end

function applylazy(op::PermuteDims{N,perm,iperm}, img::AbstractArray{T,N}) where {T,N,perm,iperm}
    PermutedDimsArray{T,N,perm,iperm,typeof(img)}(img)
end

function showconstruction(io::IO, op::PermuteDims{N,perm}) where {N,perm}
    print(io, typeof(op).name.name, '(', join(map(string, perm),", "), ')')
end

function Base.show(io::IO, op::PermuteDims{N,perm}) where {N,perm}
    if get(io, :compact, false)
        print(io, "Permute dimension order to ", perm)
    else
        print(io, typeof(op).name, '(', perm, ')')
    end
end

# --------------------------------------------------------------------

"""
    Reshape <: Augmentor.Operation

Description
--------------

Reinterpret the shape of the given array of numbers or colorants.
This is useful for example to create singleton dimensions that
deep learning frameworks may need for colorless images, or for
converting an image to a feature vector and vice versa.

Usage
--------------

    Reshape(dims)

    Reshape(dims...)

Arguments
--------------

- **`dims`** : The new sizes for each dimension of the output
    image. Has to be specified as a `Vararg{Int}` or as a
    `NTuple` of `Int`.

See also
--------------

[`CombineChannels`](@ref), [`augment`](@ref)

Examples
--------------

```julia
julia> using Augmentor, Colors

julia> A = rand(10,10)
10×10 Array{Float64,2}:
[...]

julia> augment(A, Reshape(10,10,1)) # add trailing singleton dimension
10×10×1 Array{Float64,3}:
[...]
```
"""
struct Reshape{N} <: Operation
    dims::NTuple{N,Int}
end
Reshape() = throw(MethodError(Reshape, ()))
Reshape(dims::Tuple{}) = throw(MethodError(Reshape, (dims,)))
Reshape(dims::Int...) = Reshape(dims)

@inline supports_eager(::Type{<:Reshape}) = false
@inline supports_lazy(::Type{<:Reshape}) = true

applylazy(op::Reshape, img) = reshape(img, op.dims)

function showconstruction(io::IO, op::Reshape)
    print(io, typeof(op).name.name, '(', join(map(string, op.dims),", "), ')')
end

function Base.show(io::IO, op::Reshape{N}) where N
    if get(io, :compact, false)
        if N == 1
            print(io, "Reshape array to ", first(op.dims), "-element vector")
        else
            print(io, "Reshape array to ", join(op.dims,"×"))
        end
    else
        print(io, typeof(op), '(', op.dims, ')')
    end
end
