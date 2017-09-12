# [ShearX: Shear horizontally](@id ShearX)

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
