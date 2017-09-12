# [Scale: Relative resizing](@id Scale)

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
