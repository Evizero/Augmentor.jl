"""
    PermuteDims <: Augmentor.Operation

Description
--------------

Permute the dimensions of the given array with the predefined
permutation `perm`. This operation is particularly useful if the
order of the dimensions needs to be different than the default
"julian" layout (described below).

Augmentor expects the given images to be in vertical-major layout
for which the colors are encoded in the element type itself. Many
deep learning frameworks however require their input in a
different order. For example it is not untypical that separate
color channels are expected to be encoded in the third dimension.

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

```julia-repl
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

function applyeager(op::PermuteDims{N,perm}, img::AbstractArray{T,N}, param) where {T,N,perm}
    permutedims(img, perm)
end

function applylazy(op::PermuteDims{N,perm,iperm}, img::AbstractArray{T,N}, param) where {T,N,perm,iperm}
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
This is useful for example to create singleton-dimensions that
deep learning frameworks may need for colorless images, or for
converting an image array to a feature vector (and vice versa).

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

```julia-repl
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

applylazy(op::Reshape, img::AbstractArray, param) = reshape(plain_indices(img), op.dims)

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
