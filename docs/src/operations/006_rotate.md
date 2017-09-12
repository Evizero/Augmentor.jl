# [Rotate: Arbitrary rotations](@id Rotate)

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
