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

include("operation.jl")
include("compile.jl")
include("augment.jl")

include("operations/noop.jl")
include("operations/either.jl")
include("operations/rotation.jl")
include("operations/crop.jl")

@inline plain_array(A::OffsetArray) = parent(A)
@inline plain_array(A::Array) = A
plain_array(A::AbstractArray) = plain_array(copy(A))

end # module
