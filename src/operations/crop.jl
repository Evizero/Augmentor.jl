"""
    Crop <: Augmentor.Operation

Description
--------------

Crops out the area denoted by the specified pixel ranges.

For example the operation `Crop(5:100, 2:10)` would denote a crop
for the rectangle that starts at `x=2` and `y=5` in the top left
corner and ends at `x=10` and `y=100` in the bottom right corner.
As we can see the y-axis is specified first, because that is how
the image is stored in an array. Thus the order of the provided
indices ranges needs to reflect the order of the array
dimensions.

Usage
--------------

    Crop(indices)

    Crop(indices...)

Arguments
--------------

- **`indices`** : `NTuple` or `Vararg` of `UnitRange` that denote
    the cropping range for each array dimension. This is very
    similar to how the indices for `view` are specified.

Examples
--------------

```julia
julia> using Augmentor

julia> img = testpattern()
300×400 Array{RGBA{N0f8},2}:
[...]

julia> augment(img, Crop(1:30, 361:400)) # crop upper right corner
30×40 Array{RGBA{N0f8},2}:
[...]
```

see also
--------------

[`CropNative`](@ref), [`CropSize`](@ref), [`augment`](@ref)
"""
immutable Crop{N,I<:Tuple} <: Operation
    indexes::I

    function (::Type{Crop{N}}){N}(indexes::NTuple{N,UnitRange})
        new{N,typeof(indexes)}(indexes)
    end
end
Crop(::Tuple{}) = throw(MethodError(Crop, ((),)))
Crop{N}(indexes::NTuple{N,UnitRange}) = Crop{N}(indexes)
Crop{N}(indexes::Vararg{UnitRange,N}) = Crop(indexes)
Crop(x, y, width, height) = Crop(y:y+height-1, x:x+width-1)

@inline supports_eager{T<:Crop}(::Type{T})    = false
@inline supports_affine{T<:Crop}(::Type{T})   = true
@inline supports_view{T<:Crop}(::Type{T})     = true
@inline supports_stepview{T<:Crop}(::Type{T}) = true

applyeager(op::Crop, img) = plain_array(indirect_view(img, op.indexes))

applyaffine(op::Crop, img)   = indirect_view(img, op.indexes)
applylazy(op::Crop, img)     = indirect_view(img, op.indexes)
applyview(op::Crop, img)     = indirect_view(img, op.indexes)
applystepview(op::Crop, img) = indirect_view(img, map(StepRange, op.indexes))

function Base.show{N}(io::IO, op::Crop{N})
    if get(io, :compact, false)
        if N == 2
            print(io, "Crop region $(op.indexes[1])×$(op.indexes[2])")
        else
            print(io, "Crop region $(op.indexes)")
        end
    else
        print(io, typeof(op).name, "{$N}($(op.indexes))")
    end
end

# --------------------------------------------------------------------

"""
    CropNative <: Augmentor.Operation

Description
--------------

Crops out the area denoted by the specified pixel ranges.

For example the operation `CropNative(5:100, 2:10)` would denote
a crop for the rectangle that starts at `x=2` and `y=5` in the
top left corner of native space and ends at `x=10` and `y=100` in
the bottom right corner of native space.

In contrast to [`Crop`](@ref), the position `x=1` `y=1` is not
necessarily located at the top left of the current image, but
instead depends on the cumulative effect of the previous
transformations. The reason for this is because affine
transformations are usually performed around the center of the
image, which is reflected in "native space". This is useful for
combining transformations such as [`Rotation`](@ref) or
[`ShearX`](@ref) with a crop around the center area.

Usage
--------------

    CropNative(indices)

    CropNative(indices...)

Arguments
--------------

- **`indices`** : `NTuple` or `Vararg` of `UnitRange` that denote
    the cropping range for each array dimension. This is very
    similar to how the indices for `view` are specified.

Examples
--------------

```julia
using Augmentor
img = testpattern()

# cropped at top left corner
augment(img, Rotate(45) |> Crop(1:300, 1:400))

# cropped around center of rotated image
augment(img, Rotate(45) |> CropNative(1:300, 1:400))
```

see also
--------------

[`Crop`](@ref), [`CropSize`](@ref), [`augment`](@ref)
"""
immutable CropNative{N,I<:Tuple} <: Operation
    indexes::I

    function (::Type{CropNative{N}}){N}(indexes::NTuple{N,UnitRange})
        new{N,typeof(indexes)}(indexes)
    end
end
CropNative(::Tuple{}) = throw(MethodError(CropNative, ((),)))
CropNative{N}(indexes::NTuple{N,UnitRange}) = CropNative{N}(indexes)
CropNative{N}(indexes::Vararg{UnitRange,N}) = CropNative(indexes)
CropNative(x, y, width, height) = CropNative(y:y+height-1, x:x+width-1)

@inline supports_eager{T<:CropNative}(::Type{T})    = false
@inline supports_affine{T<:CropNative}(::Type{T})   = true
@inline supports_view{T<:CropNative}(::Type{T})     = true
@inline supports_stepview{T<:CropNative}(::Type{T}) = true

applyeager(op::CropNative, img)    = plain_array(img[op.indexes...])
applyaffine(op::CropNative, img)   = direct_view(img, op.indexes)
applylazy(op::CropNative, img)     = direct_view(img, op.indexes)
applyview(op::CropNative, img)     = direct_view(img, op.indexes)
applystepview(op::CropNative, img) = direct_view(img, map(StepRange, op.indexes))

function showconstruction(io::IO, op::Union{Crop,CropNative})
    print(io, typeof(op).name.name, '(', join(map(string, op.indexes),", "), ')')
end

function Base.show{N}(io::IO, op::CropNative{N})
    if get(io, :compact, false)
        if N == 2
            print(io, "Crop native region $(op.indexes[1])×$(op.indexes[2])")
        else
            print(io, "Crop native region $(op.indexes)")
        end
    else
        print(io, typeof(op).name, "{$N}($(op.indexes))")
    end
end

# --------------------------------------------------------------------

"""
    CropSize <: Augmentor.Operation

Description
--------------

Crops out the area of the specified pixel size around the center
of the input image.

For example the operation `CropSize(10, 50)` would denote a crop
for a rectangle of height 10 and width 50 around the center of
the input image.

Usage
--------------

    CropSize(size)

    CropSize(size...)

Arguments
--------------

- **`size`** : `NTuple` or `Vararg` of `Int` that denote the
    output size for each dimension.

Examples
--------------

```julia
using Augmentor
img = testpattern()

# cropped around center of rotated image
augment(img, Rotate(45) |> CropSize(300, 400))
```

see also
--------------

[`Crop`](@ref), [`CropNative`](@ref), [`augment`](@ref)
"""
immutable CropSize{N} <: Operation
    size::NTuple{N,Int}

    function (::Type{CropSize{N}}){N}(size::NTuple{N,Int})
        all(s->s>0, size) || throw(ArgumentError("Specified sizes must be strictly greater than 0. Actual: $size"))
        new{N}(size)
    end
end
CropSize(::Tuple{}) = throw(MethodError(CropSize, ((),)))
CropSize(; width=64, height=64) = CropSize((height,width))
CropSize(size::Vararg{Int}) = CropSize(size)
CropSize{N}(size::NTuple{N,Int}) = CropSize{N}(size)

@inline supports_eager{T<:CropSize}(::Type{T}) = false
@inline supports_affine{T<:CropSize}(::Type{T}) = true
@inline supports_view{T<:CropSize}(::Type{T}) = true
@inline supports_stepview{T<:CropSize}(::Type{T}) = true

function cropsize_indices(op::CropSize, img::AbstractArray)
    cntr = convert(Tuple, center(img))
    sze = op.size
    corner = map((ci,si)->floor(Int,ci)-floor(Int,si/2)+!isinteger(ci), cntr, sze)
    map((b,s)->b:(b+s-1), corner, sze)
end

applyeager(op::CropSize, img)  = plain_array(applyview(op, img))
applylazy(op::CropSize, img)   = applyview(op, img)
applyaffine(op::CropSize, img) = applyview(op, img)

function applyview(op::CropSize, img)
    direct_view(img, cropsize_indices(op, img))
end

function applystepview(op::CropSize, img)
    direct_view(img, map(StepRange, cropsize_indices(op, img)))
end

function showconstruction(io::IO, op::CropSize)
    print(io, typeof(op).name.name, '(', join(map(string, op.size),", "), ')')
end

function Base.show{N}(io::IO, op::CropSize{N})
    if get(io, :compact, false)
        if N == 1
            print(io, "Crop a $(first(op.size))-length window at the center")
        else
            print(io, "Crop a $(join(op.size,"×")) window around the center")
        end
    else
        print(io, typeof(op), "($(op.size))")
    end
end
