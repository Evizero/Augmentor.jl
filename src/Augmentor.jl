module Augmentor

using ImageCore
using ImageTransformations
using CoordinateTransformations
using Rotations
using Interpolations
using StaticArrays
using OffsetArrays
using IdentityRanges
using Compat

export

    NoOp,
    Either,

    Rotate90,
    Rotate180,
    Rotate270,
    Crop,

    toaffine,
    augment

include("imagetransform.jl")
include("compile.jl")
include("augment.jl")

include("transforms/rotation.jl")
include("transforms/crop.jl")

_toarray(A::OffsetArray) = parent(A)
_toarray(A::Array) = A
_toarray(A::AbstractArray) = _toarray(copy(A))

end # module
