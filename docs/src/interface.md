# High-level Interface

Integrating Augmentor into an existing project should in general
not require any major changes to your code. In most cases it
should break down to the three basic steps outlined below. We
will spend the rest of this document investigating these in more
detail.

1. Import Augmentor into the namespace of your program.

   ```julia
   using Augmentor
   ```

2. Define a (stochastic) image processing pipeline by chaining
   the desired [operations](@ref operations) using `|>` and `*`.

   ```julia-repl
   julia> pl = FlipX() * FlipY() |> Zoom(0.9:0.1:1.2) |> CropSize(64,64)
   3-step Augmentor.ImmutablePipeline:
    1.) Either: (50%) Flip the X axis. (50%) Flip the Y axis.
    2.) Zoom by I ∈ {0.9×0.9, 1.0×1.0, 1.1×1.1, 1.2×1.2}
    3.) Crop a 64×64 window around the center
   ```

3. Apply the pipeline to the existing image or set of images.

   ```julia
   img_processed = augment(img_original, pl)
   ```

Depending on the complexity of your problem, you may want to
iterate between step `2.` and `3.` to identify an appropriate
pipeline.

## [Defining a Pipeline](@id pipeline)

In Augmentor, a (stochastic) image-processing pipeline can be
understood as a sequence of operations, for which the parameters
can (but need not) be random variables. What that essentially
means is that the user explicitly specifies which image operation
to perform in what order. A complete list of available operations
can be found at [Supported Operations](@ref operations).

To start off with a simple example, let us assume that we want to
first rotate our image(s) counter-clockwise by 14°, then crop
them down to the biggest possible square, and lastly resize the
image(s) to a fixed size of 64 by 64 pixel. Such a pipeline would
be defined as follows:

```jldoctest; setup = :(using Augmentor)
julia> pl = Rotate(14) |> CropRatio(1) |> Resize(64,64)
3-step Augmentor.ImmutablePipeline:
 1.) Rotate 14 degree
 2.) Crop to 1:1 aspect ratio
 3.) Resize to 64×64
```

Notice that in the example above there is no room for randomness.
In other words, the same input image would always result in the
same output image given that pipeline. If we wish for more
variation we can do so by using a vector as our parameters,
instead of a single number.

!!! note

    In this subsection we will focus only on how to define a
    pipeline, without actually thinking too much about how to
    apply that pipeline to an actual image. The later will be the
    main topic of the rest of this document.

Say we wish to adapt our pipeline such that the rotation is a
little more random. More specifically, lets say we want our image
to be rotated by either -10°, -5°, 5°, 10°, or not at all. Other
than that change we will leave the rest of the pipeline as is.

```julia-repl
julia> pl = Rotate([-10,-5,0,5,10]) |> CropRatio(1) |> Resize(64,64)
3-step Augmentor.ImmutablePipeline:
 1.) Rotate by θ ∈ [-10, -5, 0, 5, 10] degree
 2.) Crop to 1:1 aspect ratio
 3.) Resize to 64×64
```

Variation in the parameters is only one of the two main ways to
introduce randomness to our pipeline. Additionally, one can
specify that an operation should be sampled randomly from a
chosen set of operations . This can be accomplished using a
utility operation called [`Either`](@ref), which has its own
convenience syntax.

As an example, let us assume we wish to first either mirror our
image(s) horizontally, or vertically, or not at all, and then
crop it down to a size of 100 by 100 pixel around the image's
center. We can specify the "either" using the `*` operator.

```julia-repl
julia> pl = FlipX() * FlipY() * NoOp() |> CropSize(100,100)
2-step Augmentor.ImmutablePipeline:
 1.) Either: (33%) Flip the X axis. (33%) Flip the Y axis. (33%) No operation.
 2.) Crop a 100×100 window around the center
```

It is also possible to specify the odds of for such an "either".
For example we may want the [`NoOp`](@ref) to be twice as likely
as either of the mirroring options.

```julia-repl
julia> pl = (1=>FlipX()) * (1=>FlipY()) * (2=>NoOp()) |> CropSize(100,100)
2-step Augmentor.ImmutablePipeline:
 1.) Either: (25%) Flip the X axis. (25%) Flip the Y axis. (50%) No operation.
 2.) Crop a 100×100 window around the center
```

Now that we know how to define a pipeline, let us think about how
to apply it to an image or a set of images.

## The design behind operation types


The purpose of an operation is to simply serve as a "dumb
placeholder" to specify the intent and parameters of the desired
transformation. What that means is that a pipeline of operations
can be thought of as a list of instructions (a cookbook of
sorts), that Augmentor uses internally to construct the required
code that implements the desired behaviour in the most efficient
way it can.

The way an operation is implemented depends on the rest of the
specified pipeline. For example, Augmentor knows three different
ways to implement the behaviour of the operation `Rotate90` and
will choose the one that best coincides with the other operations
of the pipeline and their concrete order.

1. Call the function `rotl90` of Julia's base library, which
   makes use of the fact that a 90 degree rotation can be
   implemented very efficiently. While by itself this is the
   fastest way to compute the result, this function is "eager"
   and will allocate a new array. If `Rotate90` is followed by
   another operation this may not be the best choice, since it
   will cause a temporary image that is later discarded.

2. Create a `SubArray` of a `PermutedDimsArray`. This is more or
   less a lazy version of `rotl90` that makes use of the fact
   that a 90 degree rotation can be described 1-to-1 using just
   the original pixels. By itself this strategy is slower than
   `rotl90`, but if it is followed by an operation such as `Crop`
   or `CropSize` it can be significantly faster. The reason for
   this is that it avoids the computation of unused pixels and
   also any allocation of temporary memory. The computation
   overhead per output pixel, while small, grows linearly with
   the number of chained operations.

3. Create an `AffineMap` using a rotation matrix that describes a
   90 degree rotation around the center of the image. This will
   result in a lazy transformation of the original image that is
   further compose-able with other `AffineMap`. This is the
   slowest available strategy, unless multiple affine operations
   are chained together. If that is the case, then chaining the
   operations can be reduced to composing the tiny affine maps
   instead. This effectively fuses multiple operations into a
   single operation for which the computation overhead per output
   pixel remains approximately constant in respect to the number
   of chained operations.

## Loading the Example Image

Augmentor ships with a custom example image, which was
specifically designed for visualizing augmentation effects. It
can be accessed by calling the function `testpattern()`. That
said, doing so explicitly should rarely be necessary in practice,
because most high-level functions will default to using
`testpattern()` if no other image is specified.

```@docs
testpattern
```

```@example
using Augmentor
img = testpattern()
using Images; # hide
save(joinpath("assets","big_pattern.png"), img); # hide
nothing # hide
```

![testpattern](assets/big_pattern.png)

## Augmenting an Image

Once a pipeline is constructed it can be applied to an image
(i.e. `AbstractArray{<:ColorTypes.Colorant}`), or even just to an
array of numbers (i.e. `AbstractArray{<:Number}`), using the
function `augment`.

```@docs
augment
Augmentor.Mask
```

We also provide a mutating version of `augment` that writes the
output into preallocated memory. While this function avoids
allocation, it does have the caveat that the size of the output
image must be known beforehand (and thus must not be random).

```@docs
augment!
```

## Augmenting Image Batches

In most machine learning scenarios we will want to process a
whole batch of images at once, instead of a single image at a
time. For this reason we provide the function `augmentbatch!`,
which also supports multi-threading.

```@docs
augmentbatch!
```
