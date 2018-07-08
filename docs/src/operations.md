```@eval
using Augmentor, Images, Colors
srand(1337)
pattern = imresize(restrict(restrict(testpattern())), (60, 80))
save("assets/tiny_pattern.png", pattern)
# Affine Transformations
save("assets/tiny_FlipX.png", augment(pattern, FlipX()))
save("assets/tiny_FlipY.png", augment(pattern, FlipY()))
save("assets/tiny_Rotate90.png", augment(pattern, Rotate90()))
save("assets/tiny_Rotate270.png", augment(pattern, Rotate270()))
save("assets/tiny_Rotate180.png", augment(pattern, Rotate180()))
save("assets/tiny_Rotate.png", augment(pattern, Rotate(15)))
save("assets/tiny_ShearX.png", augment(pattern, ShearX(10)))
save("assets/tiny_ShearY.png", augment(pattern, ShearY(10)))
save("assets/tiny_Scale.png", augment(pattern, Scale(0.9,1.2)))
save("assets/tiny_Zoom.png", augment(pattern, Zoom(0.9,1.2)))
# Distortions
srand(1337)
save("assets/tiny_ED1.png", augment(pattern, ElasticDistortion(15,15,0.1)))
save("assets/tiny_ED2.png", augment(pattern, ElasticDistortion(10,10,0.2,4,3,true)))
# Resizing and Subsetting
save("assets/tiny_Resize.png", augment(pattern, Resize(60,60)))
save("assets/tiny_Crop.png", augment(pattern, Rotate(45) |> Crop(1:50,1:80)))
save("assets/tiny_CropNative.png", augment(pattern, Rotate(45) |> CropNative(1:50,1:80)))
save("assets/tiny_CropSize.png", augment(pattern, CropSize(20,65)))
save("assets/tiny_CropRatio.png", augment(pattern, CropRatio(1)))
srand(1337)
save("assets/tiny_RCropRatio.png", augment(pattern, RCropRatio(1)))
# Conversion
save("assets/tiny_ConvertEltype.png", augment(pattern, ConvertEltype(GrayA{N0f8})))
nothing;
```

# [Supported Operations](@id operations)

Augmentor provides a wide varitey of build-in image operations.
This page provides an overview of all exported operations
organized by their main category. These categories are chosen
because they serve some practical purpose. For example Affine
Operations allow for a special optimization under the hood when
chained together.

!!! tip

    Click on an image operation for more details.

## Affine Transformations

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

| **Input** |    | **[`FlipX`](@ref FlipX)** | **[`FlipY`](@ref FlipY)** | **[`Rotate90`](@ref Rotate90)** | **[`Rotate270`](@ref Rotate270)** | **[`Rotate180`](@ref Rotate180)** |
|:---------:|:--:|:-------------------:|:-------------------:|:----------------------:|:-----------------------:|:-----------------------:|
| ![](assets/tiny_pattern.png) | → | [![](assets/tiny_FlipX.png)](@ref FlipX) | [![](assets/tiny_FlipY.png)](@ref FlipY) | [![](assets/tiny_Rotate90.png)](@ref Rotate90) | [![](assets/tiny_Rotate270.png)](@ref Rotate270) | [![](assets/tiny_Rotate180.png)](@ref Rotate180) |
| **Input** |    | **[`Rotate`](@ref Rotate)** | **[`ShearX`](@ref ShearX)** | **[`ShearY`](@ref ShearY)** | **[`Scale`](@ref Scale)** | **[`Zoom`](@ref Zoom)** |
| ![](assets/tiny_pattern.png) | → | [![](assets/tiny_Rotate.png)](@ref Rotate) | [![](assets/tiny_ShearX.png)](@ref ShearX) | [![](assets/tiny_ShearY.png)](@ref ShearY) | [![](assets/tiny_Scale.png)](@ref Scale) | [![](assets/tiny_Zoom.png)](@ref Zoom) |

## Distortions

Aside from affine transformations, Augmentor also provides
functionality for performing a variety of distortions. These
types of operations usually provide a much larger distribution of
possible output images.

| **Input** |    | **[`ElasticDistortion`](@ref ElasticDistortion)** |
|:---------:|:--:|:-------------------------------------------------:|
| ![](assets/tiny_pattern.png) | → | [![](assets/tiny_ED1.png)](@ref ElasticDistortion) |

## Resizing and Subsetting

The input images from a given dataset can be of various shapes
and sizes. Yet, it is often required by the algorithm that the
data must be of uniform structure. To that end Augmentor provides
a number of ways to alter or subset given images.

| **Input** |    | **[`Resize`](@ref Resize)** |
|:---------:|:--:|:---------------------------:|
| ![](assets/tiny_pattern.png) | → | [![](assets/tiny_Resize.png)](@ref Resize) |

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

| **Input** |    | **[`Crop`](@ref Crop)** | **[`CropNative`](@ref CropNative)** | **[`CropSize`](@ref CropSize)** | **[`CropRatio`](@ref CropRatio)** | **[`RCropRatio`](@ref RCropRatio)** |
|:---------:|:--:|:------------------:|:------------------------:|:----------------------:|:-----------------------:|:------------------------:|
| ![](assets/tiny_pattern.png) | → | [![](assets/tiny_Crop.png)](@ref Crop) | [![](assets/tiny_CropNative.png)](@ref CropNative) | [![](assets/tiny_CropSize.png)](@ref CropSize) | [![](assets/tiny_CropRatio.png)](@ref CropRatio) | [![](assets/tiny_RCropRatio.png)](@ref RCropRatio) |

## Element-wise Transformations and Layout

It is not uncommon that machine learning frameworks require the
data in a specific form and layout. For example many deep
learning frameworks expect the colorchannel of the images to be
encoded in the third dimension of a 4-dimensional array.
Augmentor allows to convert from (and to) these different layouts
using special operations that are mainly useful in the beginning
or end of a augmentation pipeline.

Category              | Available Operations
----------------------|-----------------------------------------------
Conversion            | [`ConvertEltype`](@ref ConvertEltype) (e.g. convert to grayscale)
Mapping               | [`MapFun`](@ref MapFun), [`AggregateThenMapFun`](@ref AggregateThenMapFun)
Information Layout    | [`SplitChannels`](@ref SplitChannels), [`CombineChannels`](@ref CombineChannels), [`PermuteDims`](@ref PermuteDims), [`Reshape`](@ref Reshape)

## Utility Operations

Aside from "true" operations that specify some kind of
transformation, there are also a couple of special utility
operations used for functionality such as stochastic branching.

Category              | Available Operations
----------------------|-----------------------------------------------
Utility Operations    | [`NoOp`](@ref NoOp), [`CacheImage`](@ref CacheImage), [`Either`](@ref Either)
