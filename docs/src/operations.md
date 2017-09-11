# Supported Operations

This page lists and describes all supported image operations in
great detail. The operations are organized based on their
categories and subcategories.

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

Category              | Available Operations
----------------------|-----------------------------------------------
Mirroring             | [`FlipX`](@ref), [`FlipY`](@ref)
Rotating              | [`Rotate90`](@ref), [`Rotate270`](@ref), [`Rotate180`](@ref), [`Rotate`](@ref)
Shearing              | [`ShearX`](@ref), [`ShearY`](@ref)
Scaling               | [`Scale`](@ref), [`Zoom`](@ref)

## Distortions

Aside from affine transformations, Augmentor also provides
functionality for performing a variety of distortions. These
types of operations usually provide a much larger distribution of
possible output images.

Category              | Available Operations
----------------------|-----------------------------------------------
Distorting            | [`ElasticDistortion`](@ref)

## Resizing and Subsetting

The input images from a given dataset can be of various shapes
and sizes. Yet, it is often required by the algorithm that the
data must be of uniform structure. To that end Augmentor provides
a number of ways to alter or subset given images.

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


Category              | Available Operations
----------------------|-----------------------------------------------
Cropping              | [`Crop`](@ref), [`CropNative`](@ref), [`CropSize`](@ref), [`CropRatio`](@ref), [`RCropRatio`](@ref)
Resizing              | [`Resize`](@ref)

## Conversion and Layout

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

## Utility Operations

Aside from "true" operations that specify some kind of
transformation, there are also a couple of special utility
operations used for functionality such as stochastic branching.

Category              | Available Operations
----------------------|-----------------------------------------------
Utility Operations    | [`NoOp`](@ref), [`CacheImage`](@ref), [`Either`](@ref)
