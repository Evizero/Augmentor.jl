# Integration with Flux.jl

This example shows a way to use Augmentor to provide images for training
[Flux.jl](https://github.com/FluxML/Flux.jl/) models. We will be using the
[MNIST database of handwritten digits](http://yann.lecun.com/exdb/mnist/) as
our input data.

To skip all the talking and see the code, go ahead to [Complete example](@ref
flux_mnist_complete_example).

## Ordinary training

Let's first show how training looks without any augmentation.

We are using the [MLDataSets.jl](https://github.com/JuliaML/MLDataSets.jl)
package to coveniently access the MNIST dataset. To reduce the training time,
we are working only with a subset of the data.

After collecting the data, we divide them into batches using `batchview` from
[MLDataUtils.jl](https://github.com/JuliaML/MLDataUtils.jl). We then create a
model, pick a loss function and an optimizer, and start the training.

```@example flux
using Flux, MLDatasets, MLDataUtils

n_instances = 32
batch_size = 32
n_epochs = 16

# Flux requires a 4D numerical array in WHCN (width, height, channel, batch)
# format thus we need to insert a dummy dimension to indicate `C=1`(gray image).
X = Flux.unsqueeze(MNIST.traintensor(Float32, 1:n_instances), 3)
y = Flux.onehotbatch(MNIST.trainlabels(1:n_instances), 0:9)

# size(X) == (28, 28, 1, 32)
# size(y) == (10, 32)
@assert size(X) == (28, 28, 1, 32) # hide
@assert size(y) == (10, 32) # hide

# `data = batches[1]` means the first batch input:
#     - `data[1]` is a batch extracted from `X`
#     - `data[2]` is a batch extracted from `y`
# We also apply `shuffleobs` to get a random batch view.
batches = batchview(shuffleobs((X, y)), maxsize=batch_size)

predict = Chain(Conv((3, 3), 1=>16, pad=(1, 1), relu),
                MaxPool((2,2)),
                Conv((3, 3), 16=>32, pad=(1, 1), relu),
                MaxPool((2,2)),
                Conv((3, 3), 32=>32, pad=(1, 1), relu),
                MaxPool((2, 2)),
                flatten,
                Dense(288, 10))

loss(X, y) = Flux.Losses.logitcrossentropy(predict(X), y)

opt = Flux.Optimise.ADAM(0.001)

for epoch in 1:n_epochs
    Flux.train!(loss, params(predict), batches, opt)
end

nothing # hide
```

## Adding augmentation

Augmentor aims to provide generic image augmentation support for any machine
learning framework and not just deep learning. Except for the grayscale images,
Augmentor assumes every image is an array of `Colorant`. Without loss of
generality, we use `Gray` image here so that the same pipeline also applies to
`RGB` image.

!!! warning "Use colorant array whenever you can"
    If you pass a 3d numerical array, e.g., of size `(28, 28, 3)` and interpret
    it as an RGB array, you'll almost definitely get an incorrect result from
    Augmentor. This is because Augmentor and the entire JuliaImages ecosystem
    uses `Array{RGB{Float32}, 2}` to represent an `RGB` array. Without any
    explicit note, `Array{Float32, 3}` will be interpreted as a 3d gray image
    instead of any colorful image. Just think of the color specifications like
    `Lab`, `HSV` and you'll notice the ambiguity here.

```@example flux
using ImageCore

X = Gray.(MNIST.traintensor(Float32, 1:n_instances))
y = Flux.onehotbatch(MNIST.trainlabels(1:n_instances), 0:9)

nothing # hide
```

Augmentation is given by an augmentation pipeline. Our pipeline is a
composition of three operations:

  1. [`ElasticDistortion`](@ref) is the only image operation in this pipeline.
  2. [`SplitChannels`](@ref) split the colorant array into the plain numerical
     array so that deep learning frameworks are happy with the layout.
  2. [`PermuteDims`](@ref) permutes the dimension of each image to match WHC.

The operations are composed by the `|>` operator.

```@example flux
using Augmentor

pl = ElasticDistortion(6, 6,
                       sigma=4,
                       scale=0.3,
                       iter=3,
                       border=true) |>
     SplitChannels() |>
     PermuteDims((2, 3, 1))
```

Next, we define two helper functions.

```@example flux
# Creates an output array for augmented images
outbatch(X) = Array{Float32}(undef, (28, 28, 1, nobs(X)))
# Takes a batch (images and targets) and augments the images
augmentbatch((X, y)) = (augmentbatch!(outbatch(X), X, pl), y)

nothing # hide
```

In many deep learning tasks, the augmentation is applied lazily during the data
iteration. For this purpose, we wrap the batches with a [mapped
array](https://github.com/JuliaArrays/MappedArrays.jl/) in order to augment
each batch right before feeding it to the network.

```@example flux
using MappedArrays

batches = batchview((X, y), maxsize=batch_size)
batches = mappedarray(augmentbatch, batches)
# eager alternative: augmentation happens when this line gets executed
# batches = augmentbatch.(batches)

# The output is already in the expected WHCN format
# size(batches[1][1]) == (28, 28, 1, 32)
# size(batches[1][2]) == (10, 32)
@assert size(batches[1][1]) == (28, 28, 1, 32) # hide
@assert size(batches[1][2]) == (10, 32) # hide

nothing # hide
```

Iterating over batches will now produce augmented images. No other changes are
required.

## [Complete example](@id flux_mnist_complete_example)

```@example
using Augmentor, Flux, ImageCore, MappedArrays, MLDatasets, MLDataUtils

n_instances = 32
batch_size = 32
n_epochs = 16

X = Gray.(MNIST.traintensor(Float32, 1:n_instances))
y = Flux.onehotbatch(MNIST.trainlabels(1:n_instances), 0:9)

pl = ElasticDistortion(6, 6,
                       sigma=4,
                       scale=0.3,
                       iter=3,
                       border=true) |>
     SplitChannels() |>
     PermuteDims((2, 3, 1))

outbatch(X) = Array{Float32}(undef, (28, 28, 1, nobs(X)))
augmentbatch((X, y)) = (augmentbatch!(outbatch(X), X, pl), y)

batches = mappedarray(augmentbatch, batchview((X, y), maxsize=batch_size))

predict = Chain(Conv((3, 3), 1=>16, pad=(1, 1), relu),
                MaxPool((2,2)),
                Conv((3, 3), 16=>32, pad=(1, 1), relu),
                MaxPool((2,2)),
                Conv((3, 3), 32=>32, pad=(1, 1), relu),
                MaxPool((2, 2)),
                flatten,
                Dense(288, 10))

loss(X, y) = Flux.Losses.logitcrossentropy(predict(X), y)

opt = Flux.Optimise.ADAM(0.001)

for epoch in 1:n_epochs
    Flux.train!(loss, params(predict), batches, opt)
end
```
