# Semantic Wrappers

Semantic wrappers are used to define a meaning of an input and
consequently, determine what operations can be applied on that input.

Each semantic wrapper is expected to implement constructor which takes
the original object and wraps it, and the [`Augmentor.unwrap`](@ref) method,
which returns the wrapped object. I.e., for a wrapper `W`, the following holds:
`obj == unwrap(W(obj))`.

To prevent name conflicts, it is suggested not to export any semantic wrappers.

```@docs
Augmentor.SemanticWrapper
Augmentor.unwrap
```
