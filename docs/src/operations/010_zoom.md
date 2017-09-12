# [Zoom: Scale without resize](@id Zoom)

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
