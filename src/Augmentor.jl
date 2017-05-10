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
using Base.PermutedDimsArrays: PermutedDimsArray

export

    Either,

    NoOp,
    Rotate90,
    Rotate180,
    Rotate270,
    Rotate,
    Crop,

    augment

include("utils.jl")
include("types.jl")
include("operation.jl")
include("pipeline.jl")
include("compile.jl")
include("augment.jl")

include("operations/noop.jl")
include("operations/either.jl")
include("operations/rotation.jl")
include("operations/crop.jl")

end # module
