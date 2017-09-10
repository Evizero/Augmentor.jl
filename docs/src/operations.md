# Supported Operations

This page lists and describes all supported image operations in
great detail. The operations are organized based on their
categories and subcategories.

A sizeable amount of the provided operations fall under the
category of **affine transformations**. As such, they can be
described using what is known as an [affine
map](https://en.wikipedia.org/wiki/Affine_transformation), which
are inherently compose-able if chained together. However,
utilizing such a affine formulation requires (costly)
interpolation, which may not always be needed to achieve the
desired effect. For that reason do some of the operations below
also provide a special purpose implementation to produce their
specified result. Those are usually preferred over the affine
formulation if sensible considering the complete pipeline.

Category              | Available Operations
----------------------|-----------------------------------------------
Mirroring             | [`FlipX`](@ref), [`FlipY`](@ref)
Rotating              | [`Rotate90`](@ref), [`Rotate270`](@ref), [`Rotate180`](@ref), [`Rotate`](@ref)
Shearing              | [`ShearX`](@ref), [`ShearY`](@ref)
Scaling               | [`Scale`](@ref), [`Zoom`](@ref), [`Resize`](@ref)

Aside from affine transformations, Augmentor also provides
functionality for performing a variety of distortions. These
types of operations usually provide a much larger distribution of
possible output images.

Category              | Available Operations
----------------------|-----------------------------------------------
Distorting            | [`ElasticDistortion`](@ref)

The input images from a given dataset can be of various shapes
and sizes. Yet, it is often required by the algorithm that the
data must be of uniform structure. To that end Augmentor provides
a number of ways to alter or subset given images.

Category              | Available Operations
----------------------|-----------------------------------------------
Cropping              | [`Crop`](@ref), [`CropNative`](@ref), [`CropSize`](@ref), [`CropRatio`](@ref), [`RCropRatio`](@ref)
Resizing              | [`Resize`](@ref)

It is not uncommon that machine learning frameworks require the
data in a specific form and layout. For example many deep
learning frameworks expect the colorchannel of the images to be
encoded in the third dimension of a 4-dimensional array.
Augmentor allows to convert from (and to) these different layouts
using special operations that are mainly useful in the beginning
or end of a augmentation pipeline.

Category              | Available Operations
----------------------|-----------------------------------------------
Conversion            | [`ConvertEltype`](@ref)
Information Layout    | [`SplitChannels`](@ref), [`CombineChannels`](@ref), [`PermuteDims`](@ref), [`Reshape`](@ref)

Aside from "true" operations that specify some kind of
transformation, there are also a couple of special utility
operations used for functionality such as stochastic branching.

Category              | Available Operations
----------------------|-----------------------------------------------
Utility Operations    | [`NoOp`](@ref), [`CacheImage`](@ref), [`Either`](@ref)

```@eval
using Augmentor, Images
pattern = imresize(testpattern(), (240, 320))
save("assets/testpattern.png", pattern)
```

## Mirroring

```@docs
FlipX
```
```@eval
include("optable.jl")
@optable FlipX()
```

----

```@docs
FlipY
```
```@eval
include("optable.jl")
@optable FlipY()
```

## Rotating

```@docs
Rotate90
```
```@eval
include("optable.jl")
@optable Rotate90()
```

----

```@docs
Rotate180
```
```@eval
include("optable.jl")
@optable Rotate180()
```

----

```@docs
Rotate270
```
```@eval
include("optable.jl")
@optable Rotate270()
```

----

```@docs
Rotate
```

In contrast to the special case rotations outlined above, the
type `Rotate` can describe any arbitrary number of degrees. It
will always perform the rotation around the center of the image.
This can be particularly useful when combining the operation with
[`CropNative`](@ref).

```@eval
include("optable.jl")
@optable Rotate(15)
```

It is also possible to pass some abstract vector to the
constructor, in which case Augmentor will randomly sample one of
its elements every time the operation is applied.

```@eval
include("optable.jl")
@optable 10 => Rotate(-10:10)
```

## Shearing

```@docs
ShearX
```

It will always perform the transformation around the center of
the image. This can be particularly useful when combining the
operation with [`CropNative`](@ref).

```@eval
include("optable.jl")
@optable ShearX(10)
```

It is also possible to pass some abstract vector to the
constructor, in which case Augmentor will randomly sample one of
its elements every time the operation is applied.

```@eval
include("optable.jl")
@optable 10 => ShearX(-10:10)
```

----

```@docs
ShearY
```

It will always perform the transformation around the center of
the image. This can be particularly useful when combining the
operation with [`CropNative`](@ref).

```@eval
include("optable.jl")
@optable ShearY(10)
```

It is also possible to pass some abstract vector to the
constructor, in which case Augmentor will randomly sample one of
its elements every time the operation is applied.

```@eval
include("optable.jl")
@optable 10 => ShearY(-10:10)
```

## Scaling

```@docs
Scale
```
```@eval
include("optable.jl")
@optable Scale(0.9,0.5)
```

In the case that only a single scale factor is specified, the
operation will assume that the intention is to scale all
dimensions uniformly by that factor.

```@eval
include("optable.jl")
@optable Scale(1.2)
```

It is also possible to pass some abstract vector(s) to the
constructor, in which case Augmentor will randomly sample one of
its elements every time the operation is applied.

```@eval
include("optable.jl")
@optable 10 => Scale(0.9:0.05:1.2)
```

----

```@docs
Zoom
```
```@eval
include("optable.jl")
@optable Zoom(1.2)
```

It is also possible to pass some abstract vector to the
constructor, in which case Augmentor will randomly sample one of
its elements every time the operation is applied.

```@eval
include("optable.jl")
@optable 10 => Zoom(0.9:0.05:1.3)
```

## Resizing

```@docs
Resize
```
```@eval
include("optable.jl")
@optable Resize(100,150)
```

## Distorting

```@docs
ElasticDistortion
```
```@eval
include("optable.jl")
@optable 10 => ElasticDistortion(15,15,0.1)
```

```@eval
include("optable.jl")
@optable 10 => ElasticDistortion(10,10,0.2,4,3,true)
```

## Cropping

The process of cropping is useful to discard parts of the input
image. To provide this functionality lazily, applying a crop
introduces a layer of representation called a "view" or
`SubArray`. This is different yet compatible with how affine
operations or other special purpose implementations work. This
means that chaining a crop with some affine operation is
perfectly fine if done sequentially. However, it is generally not
advised to combine affine operations with crop operations within
an [`Either`](@ref) block. Doing that would force the
[`Either`](@ref) to trigger the eager computation of its branches
in order to preserve type-stability.

```@docs
Crop
```
```@eval
include("optable.jl")
@optable Crop(70:140,25:155)
```

----

```@docs
CropNative
```
```@eval
include("optable.jl")
@optable "cropn1" => (Rotate(45),Crop(1:210,1:280))
@optable "cropn2" => (Rotate(45),CropNative(1:210,1:280))
tbl = string(
    "`(Rotate(45), Crop(1:210,1:280))` | `(Rotate(45), CropNative(1:210,1:280))`\n",
    "-----|-----\n",
    "![input](assets/cropn1.png) | ![output](assets/cropn2.png)\n"
)
Markdown.parse(tbl)
```

----

```@docs
CropSize
```
```@eval
include("optable.jl")
@optable CropSize(45,225)
```

----

```@docs
CropRatio
```
```@eval
include("optable.jl")
@optable CropRatio(1)
```

----

```@docs
RCropRatio
```
```@eval
include("optable.jl")
@optable 10 => RCropRatio(1)
```

## Conversion

```@docs
ConvertEltype
```
```@eval
include("optable.jl")
@optable ConvertEltype(Gray)
```

## Color Channels

```@docs
SplitChannels
```

----

```@docs
CombineChannels
```

## Array Shape

```@docs
PermuteDims
```

----

```@docs
Reshape
```

## Utility Operations

```@docs
CacheImage
```

----

```@docs
NoOp
```

----

```@docs
Either
```
