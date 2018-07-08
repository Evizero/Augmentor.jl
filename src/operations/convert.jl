"""
    ConvertEltype <: Augmentor.Operation

Description
--------------

Convert the element type of the given array/image into the given
`eltype`. This operation is especially useful for converting
color images to grayscale (or the other way around). That said,
the operation is not specific to color types and can also be used
for numeric arrays (e.g. with separated channels).

Note that this is an element-wise convert function. Thus it can
not be used to combine or separate color channels. Use
[`SplitChannels`](@ref) or [`CombineChannels`](@ref) for those
purposes.

Usage
--------------

    ConvertEltype(eltype)

Arguments
--------------

- **`eltype`** : The eltype of the resulting array/image.

See also
--------------

[`CombineChannels`](@ref), [`SplitChannels`](@ref), [`augment`](@ref)

Examples
--------------

```julia-repl
julia> using Augmentor, Colors

julia> A = rand(RGB, 10, 10) # three color channels
10×10 Array{RGB{Float64},2}:
[...]

julia> augment(A, ConvertEltype(Gray{Float32})) # convert to grayscale
10×10 Array{Gray{Float32},2}:
[...]
```
"""
struct ConvertEltype{T} <: Operation
    eltype::Type{T}
end

@inline supports_lazy(::Type{<:ConvertEltype}) = true

function applyeager(op::ConvertEltype{T}, img::AbstractArray, param) where T
    maybe_copy(convert(AbstractArray{T}, img))
end

function applylazy(op::ConvertEltype{T}, img::AbstractArray, param) where T
    mappedarray(c->convert(T,c), img)
end

function showconstruction(io::IO, op::ConvertEltype)
    print(io, typeof(op).name.name, '(')
    _showcolor(io, op.eltype)
    print(io, ')')
end

function Base.show(io::IO, op::ConvertEltype)
    if get(io, :compact, false)
        print(io, "Convert eltype to ")
        _showcolor(io, op.eltype)
    else
        print(io, "Augmentor.")
        showconstruction(io, op)
    end
end
