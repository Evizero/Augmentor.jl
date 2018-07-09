"""
    Crop <: Augmentor.ImageOperation

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

See also
--------------

[`CropNative`](@ref), [`CropSize`](@ref), [`CropRatio`](@ref), [`augment`](@ref)

Examples
--------------

```julia-repl
julia> using Augmentor

julia> img = testpattern()
300×400 Array{RGBA{N0f8},2}:
[...]

julia> augment(img, Crop(1:30, 361:400)) # crop upper right corner
30×40 Array{RGBA{N0f8},2}:
[...]
```
"""
struct Crop{N,I<:Tuple} <: ImageOperation
    indexes::I

    function Crop{N}(indexes::NTuple{N,UnitRange}) where N
        new{N,typeof(indexes)}(indexes)
    end
end
function Crop(indexes::NTuple{N,AbstractUnitRange}) where N
    Crop{N}(map(UnitRange, indexes))
end
Crop(::Tuple{}) = throw(MethodError(Crop, ((),)))
Crop(indexes::Range...) = Crop(indexes)

@inline supports_eager(::Type{<:Crop})      = false
@inline supports_affineview(::Type{<:Crop}) = true
@inline supports_view(::Type{<:Crop})       = true
@inline supports_stepview(::Type{<:Crop})   = true

@inline applylazy(op::Crop, img::AbstractArray, param) = applyview(op, img, param)

function applyaffineview(op::Crop, img::AbstractArray, param)
    applyview(op, prepareaffine(img), param)
end

function applyview(op::Crop, img::AbstractArray, param)
    indirect_view(img, op.indexes)
end

function applystepview(op::Crop, img::AbstractArray, param)
    indirect_view(img, map(StepRange, op.indexes))
end

function Base.show(io::IO, op::Crop{N}) where N
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
    CropNative <: Augmentor.ImageOperation

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
combining transformations such as [`Rotate`](@ref) or
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

See also
--------------

[`Crop`](@ref), [`CropSize`](@ref), [`CropRatio`](@ref), [`augment`](@ref)

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
"""
struct CropNative{N,I<:Tuple} <: ImageOperation
    indexes::I

    function CropNative{N}(indexes::NTuple{N,UnitRange}) where N
        new{N,typeof(indexes)}(indexes)
    end
end
function CropNative(indexes::NTuple{N,AbstractUnitRange}) where N
    CropNative{N}(map(UnitRange, indexes))
end
CropNative(::Tuple{}) = throw(MethodError(CropNative, ((),)))
CropNative(indexes::Range...) = CropNative(indexes)

@inline supports_eager(::Type{<:CropNative})      = false
@inline supports_affineview(::Type{<:CropNative}) = true
@inline supports_view(::Type{<:CropNative})       = true
@inline supports_stepview(::Type{<:CropNative})   = true

@inline applylazy(op::CropNative, img::AbstractArray, param) = applyview(op, img, param)

function applyaffineview(op::CropNative, img::AbstractArray, param)
    applyview(op, prepareaffine(img), param)
end

function applyview(op::CropNative, img::AbstractArray, param)
    direct_view(img, op.indexes)
end

function applystepview(op::CropNative, img::AbstractArray, param)
    direct_view(img, map(StepRange, op.indexes))
end

function showconstruction(io::IO, op::Union{Crop,CropNative})
    print(io, typeof(op).name.name, '(', join(map(string, op.indexes),", "), ')')
end

function Base.show(io::IO, op::CropNative{N}) where N
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
    CropSize <: Augmentor.ImageOperation

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
    output size in pixel for each dimension.

See also
--------------

[`CropRatio`](@ref), [`Crop`](@ref), [`CropNative`](@ref), [`augment`](@ref)

Examples
--------------

```julia
using Augmentor
img = testpattern()

# cropped around center of rotated image
augment(img, Rotate(45) |> CropSize(300, 400))
```
"""
struct CropSize{N} <: ImageOperation
    size::NTuple{N,Int}

    function CropSize{N}(size::NTuple{N,Int}) where N
        all(s->s>0, size) || throw(ArgumentError("Specified sizes must be strictly greater than 0. Actual: $size"))
        new{N}(size)
    end
end
CropSize(::Tuple{}) = throw(MethodError(CropSize, ((),)))
CropSize(size::NTuple{N,Int}) where {N} = CropSize{N}(size)
CropSize(size::Int...) = CropSize(size)
CropSize(; width=64, height=64) = CropSize((height,width))

@inline supports_eager(::Type{<:CropSize})      = false
@inline supports_affineview(::Type{<:CropSize}) = true
@inline supports_view(::Type{<:CropSize})       = true
@inline supports_stepview(::Type{<:CropSize})   = true

function cropsize_indices(op::CropSize, img::AbstractArray)
    cntr = convert(Tuple, center(img))
    sze = op.size
    corner = map((ci,si)->floor(Int,ci)-floor(Int,si/2)+!isinteger(ci), cntr, sze)
    map((b,s)->b:(b+s-1), corner, sze)
end

@inline applylazy(op::CropSize, img::AbstractArray, param) = applyview(op, img, param)

function applyaffineview(op::CropSize, img::AbstractArray, param)
    applyview(op, prepareaffine(img), param)
end

function applyview(op::CropSize, img::AbstractArray, param)
    direct_view(img, cropsize_indices(op, img))
end

function applystepview(op::CropSize, img::AbstractArray, param)
    direct_view(img, map(StepRange, cropsize_indices(op, img)))
end

function showconstruction(io::IO, op::CropSize)
    print(io, typeof(op).name.name, '(', join(map(string, op.size),", "), ')')
end

function Base.show(io::IO, op::CropSize{N}) where N
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

# --------------------------------------------------------------------

"""
    CropRatio <: Augmentor.ImageOperation

Description
--------------

Crops out the biggest area around the center of the given image
such that the output image satisfies the specified aspect ratio
(i.e. width divided by height).

For example the operation `CropRatio(1)` would denote a crop
for the biggest square around the center of the image.

For randomly placed crops take a look at [`RCropRatio`](@ref).

Usage
--------------

    CropRatio(ratio)

    CropRatio(; ratio = 1)

Arguments
--------------

- **`ratio::Number`** : Optional. A number denoting the aspect
    ratio. For example specifying `ratio=16/9` would denote a 16:9
    aspect ratio. Defaults to `1`, which describes a square crop.

See also
--------------

[`RCropRatio`](@ref), [`CropSize`](@ref), [`Crop`](@ref), [`CropNative`](@ref), [`augment`](@ref)

Examples
--------------

```julia
using Augmentor
img = testpattern()

# crop biggest square around the image center
augment(img, CropRatio(1))
```
"""
struct CropRatio <: ImageOperation
    ratio::Float64

    function CropRatio(ratio::Real)
        ratio > 0 || throw(ArgumentError("ratio has to be greater than 0"))
        new(Float64(ratio))
    end
end
CropRatio(; ratio = 1.) = CropRatio(ratio)

@inline supports_eager(::Type{CropRatio})      = false
@inline supports_affineview(::Type{CropRatio}) = true
@inline supports_view(::Type{CropRatio})       = true
@inline supports_stepview(::Type{CropRatio})   = true

function cropratio_indices(op::CropRatio, img::AbstractMatrix)
    h, w = map(length, indices(img))
    ratio = op.ratio
    # compute new size based on ratio
    nw = floor(Int, h * ratio)
    nh = floor(Int, w / ratio)
    nw = nw > 1 ? nw : 1
    nh = nh > 1 ? nh : 1
    sze = nh < h ? nh : h, nw < w ? nw : w
    # compute indices around center for given size
    cntr = convert(Tuple, center(img))
    corner = map((ci,si)->floor(Int,ci)-floor(Int,si/2)+!isinteger(ci), cntr, sze)
    map((b,s)->b:(b+s-1), corner, sze)
end

@inline applylazy(op::CropRatio, img::AbstractArray, param) = applyview(op, img, param)

function applyaffineview(op::CropRatio, img::AbstractArray, param)
    applyview(op, prepareaffine(img), param)
end

function applyview(op::CropRatio, img::AbstractArray, param)
    direct_view(img, cropratio_indices(op, img))
end

function applystepview(op::CropRatio, img::AbstractArray, param)
    direct_view(img, map(StepRange, cropratio_indices(op, img)))
end

function ratio2str(ratio)
    high0 = if ratio >= 1
        ratio
    else
        1 / ratio
    end
    low, high = 1, high0
    found = false
    for i = 1:20
        high = i * high0
        if round(high) == round(high,2)
            low = i
            found = true
            break
        end
    end
    if !found
        string(round(ratio,2))
    elseif ratio >= 1
        string(round(Int,high), ':', low)
    else
        string(low, ':', round(Int,high))
    end
end

function Base.show(io::IO, op::CropRatio)
    if get(io, :compact, false)
        print(io, "Crop to ", ratio2str(op.ratio), " aspect ratio")
    else
        print(io, "Augmentor.")
        showconstruction(io, op)
    end
end

# --------------------------------------------------------------------

"""
    RCropRatio <: Augmentor.ImageOperation

Description
--------------

Crops out the biggest possible area at some random position of
the given image, such that the output image satisfies the
specified aspect ratio (i.e. width divided by height).

For example the operation `RCropRatio(1)` would denote a crop for
the biggest possible square. If there is more than one such
square, then one will be selected at random.

Usage
--------------

    RCropRatio(ratio)

    RCropRatio(; ratio = 1)

Arguments
--------------

- **`ratio::Number`** : Optional. A number denoting the aspect
    ratio. For example specifying `ratio=16/9` would denote a 16:9
    aspect ratio. Defaults to `1`, which describes a square crop.

See also
--------------

[`CropRatio`](@ref), [`CropSize`](@ref), [`Crop`](@ref), [`CropNative`](@ref), [`augment`](@ref)

Examples
--------------

```julia
using Augmentor
img = testpattern()

# crop a randomly placed square of maxmimum size
augment(img, RCropRatio(1))
```
"""
struct RCropRatio <: ImageOperation
    ratio::Float64

    function RCropRatio(ratio::Real)
        ratio > 0 || throw(ArgumentError("ratio has to be greater than 0"))
        new(Float64(ratio))
    end
end
RCropRatio(; ratio = 1.) = RCropRatio(ratio)

@inline supports_eager(::Type{RCropRatio})      = false
@inline supports_affineview(::Type{RCropRatio}) = true
@inline supports_view(::Type{RCropRatio})       = true
@inline supports_stepview(::Type{RCropRatio})   = true

function rcropratio_indices(op::RCropRatio, img::AbstractMatrix)
    h, w = map(length, indices(img))
    ratio = op.ratio
    # compute new size based on ratio
    nw = floor(Int, h * ratio)
    nh = floor(Int, w / ratio)
    nw = nw > 1 ? nw : 1
    nh = nh > 1 ? nh : 1
    # place window at a random place
    if nw == w || nh == h
        1:h, 1:w
    elseif nw < w
        x_max = w - nw + 1
        @assert x_max > 0
        x = safe_rand(1:x_max)
        1:h, x:(x+nw-1)
    elseif nh < h
        y_max = h - nh + 1
        @assert y_max > 0
        y = safe_rand(1:y_max)
        y:(y+nh-1), 1:w
    else
        error("unreachable code reached")
    end
end

randparam(op::RCropRatio, imgs::Tuple) = rcropratio_indices(op, imgs[1])
randparam(op::RCropRatio, img::AbstractArray) = rcropratio_indices(op, img)

function applylazy(op::RCropRatio, img::AbstractArray, inds)
    applyview(op, img, inds)
end

function applyaffineview(op::RCropRatio, img::AbstractArray, inds)
    applyview(op, prepareaffine(img), inds)
end

function applyview(op::RCropRatio, img::AbstractArray, inds)
    indirect_view(img, inds)
end

function applystepview(op::RCropRatio, img::AbstractArray, inds)
    indirect_view(img, map(StepRange, inds))
end

function showconstruction(io::IO, op::Union{RCropRatio,CropRatio})
    print(io, typeof(op).name.name, '(', op.ratio, ')')
end

function Base.show(io::IO, op::RCropRatio)
    if get(io, :compact, false)
        print(io, "Crop random window with ", ratio2str(op.ratio), " aspect ratio")
    else
        print(io, "Augmentor.")
        showconstruction(io, op)
    end
end
