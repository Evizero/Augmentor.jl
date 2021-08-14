# Integration with Flux.jl

This example shows a way to use Augmentor to provide images for training
[Flux.jl](https://github.com/FluxML/Flux.jl/) models. We will be using the
[MNIST database of handwritten digits](http://yann.lecun.com/exdb/mnist/) as
our input data.

To skip all the talking and see the code, go ahead to [Complete example](@ref flux_mnist_complete_example).

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

X = Flux.unsqueeze(MNIST.traintensor(Float32, 1:n_instances), 3)
y = Flux.onehotbatch(MNIST.trainlabels(1:n_instances), 0:9)

# size(X) == (28, 28, 1, 32)
# size(y) == (10, 32)

batches = batchview((X, y), maxsize=batch_size)

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

First of all, we remove `Flux.unsqueeze` from the image tensor. This is
required for Augmentor to correctly process the batches.

```@example flux
X = MNIST.traintensor(Float32, 1:n_instances)

nothing # hide
```

Augmentation is given by an augmentation pipeline. Our pipeline is a
composition of two operations:

  1. [`ElasticDistortion`](@ref) is the only image operation in this pipeline,
  2. [`Reshape`](@ref) adds the singleton dimension that is required by Flux.

The operations are composed by the `|>` operator.

```@example flux
using Augmentor

pl = ElasticDistortion(6, 6,
                       sigma=4,
                       scale=0.3,
                       iter=3,
                       border=true) |>
     Reshape(28, 28, 1)
```

Next, we define two helper functions.

```@example flux
# Creates an output array for augmented images
outbatch(X) = Array{Float32}(undef, (28, 28, 1, nobs(X)))
# Takes a batch (images and targets) and augments the images
augmentbatch((X, y)) = (augmentbatch!(outbatch(X), X, pl), y)

nothing # hide
```

Finally, we wrap the batches with a [mapped
array](https://github.com/JuliaArrays/MappedArrays.jl/) in order to augment
each batch.

```@example flux
using MappedArrays

batches = mappedarray(augmentbatch, batchview((X, y), maxsize=batch_size))

nothing # hide
```

Iterating over batches will now produce augmented images. No other changes are
required.

## Complete example

```@example
using Augmentor, Flux, MappedArrays, MLDatasets, MLDataUtils

n_instances = 32
batch_size = 32
n_epochs = 16

X = MNIST.traintensor(Float32, 1:n_instances)
y = Flux.onehotbatch(MNIST.trainlabels(1:n_instances), 0:9)

pl = ElasticDistortion(6, 6,
                       sigma=4,
                       scale=0.3,
                       iter=3,
                       border=true) |>
     Reshape(28, 28, 1)

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
