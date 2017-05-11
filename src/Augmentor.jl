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

    NoOp,

    Either,

    Rotate90,
    Rotate180,
    Rotate270,
    Rotate,

    ShearX,
    ShearY,

    FlipX,
    FlipY,

    Crop,

    Resize,

    Scale,
    Zoom,

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
include("operations/shear.jl")
include("operations/flip.jl")
include("operations/crop.jl")
include("operations/resize.jl")
include("operations/scale.jl")
include("operations/zoom.jl")

end # module
