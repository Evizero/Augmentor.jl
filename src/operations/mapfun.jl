"""
    MapFun <: Augmentor.Operation

Description
--------------

Maps the given function over all individual array elements.

This means that the given function is called with an individual
elements and is expected to return a transformed element that
should take the original's place. This further implies that the
function is expected to be unary. It is encouraged that the
function should be consistent with its return type and
type-stable.

Usage
--------------

    MapFun(fun)

Arguments
--------------

- **`fun`** : The unary function that should be mapped over all
    individual array elements.

See also
--------------

[`AggregateThenMapFun`](@ref), [`ConvertEltype`](@ref), [`augment`](@ref)

Examples
--------------

```julia
using Augmentor, ColorTypes
img = testpattern()

# subtract the constant RGBA value from each pixel
augment(img, MapFun(px -> px - RGBA(0.5, 0.3, 0.7, 0.0)))

# separate channels to scale each numeric element by a constant value
pl = SplitChannels() |> MapFun(el -> el * 0.5) |> CombineChannels(RGBA)
augment(img, pl)
```
"""
struct MapFun{T} <: Operation
    fun::T
end

@inline supports_lazy(::Type{<:MapFun}) = true

function applyeager(op::MapFun, img::AbstractArray, param)
    maybe_copy(map(op.fun, img))
end

function applylazy(op::MapFun, img::AbstractArray, param)
    mappedarray(op.fun, img)
end

function showconstruction(io::IO, op::MapFun)
    print(io, typeof(op).name.name, '(', op.fun, ')')
end

function Base.show(io::IO, op::MapFun)
    if get(io, :compact, false)
        print(io, "Map function \"", op.fun, "\" over image")
    else
        print(io, "Augmentor.")
        showconstruction(io, op)
    end
end

# --------------------------------------------------------------------

"""
    AggregateThenMapFun <: Augmentor.Operation

Description
--------------

Compute some aggregated value of the current image using the
given function `aggfun`, and map that value over the current
image using the given function `mapfun`.

This is particularly useful for achieving effects such as
per-image normalization.

Usage
--------------

    AggregateThenMapFun(aggfun, mapfun)

Arguments
--------------

- **`aggfun`** : A function that takes the whole current image as
    input and which result will also be passed to `mapfun`. It
    should have a signature of `img -> agg`, where `img` will the
    the current image. What type and value `agg` should be is up
    to the user.

- **`mapfun`** : The binary function that should be mapped over
    all individual array elements. It should have a signature of
    `(px, agg) -> new_px` where `px` is a single element of the
    current image, and `agg` is the output of `aggfun`.

See also
--------------

[`MapFun`](@ref), [`ConvertEltype`](@ref), [`augment`](@ref)

Examples
--------------

```julia
using Augmentor
img = testpattern()

# subtract the average RGB value of the current image
augment(img, AggregateThenMapFun(img -> mean(img), (px, agg) -> px - agg))
```
"""
struct AggregateThenMapFun{A,M} <: Operation
    aggfun::A
    mapfun::M
end

@inline supports_lazy(::Type{<:AggregateThenMapFun}) = true

function applyeager(op::AggregateThenMapFun, img::AbstractArray, param)
    agg = op.aggfun(img)
    maybe_copy(map(x -> op.mapfun(x, agg), img))
end

function applylazy(op::AggregateThenMapFun, img::AbstractArray, param)
    agg = op.aggfun(img)
    mappedarray(x -> op.mapfun(x, agg), img)
end

function showconstruction(io::IO, op::AggregateThenMapFun)
    print(io, typeof(op).name.name, '(', op.aggfun, ", ", op.mapfun, ')')
end

function Base.show(io::IO, op::AggregateThenMapFun)
    if get(io, :compact, false)
        print(io, "Map result of \"", op.aggfun, "\" using \"", op.mapfun, "\" over image")
    else
        print(io, "Augmentor.")
        showconstruction(io, op)
    end
end
