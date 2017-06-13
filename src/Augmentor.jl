__precompile__()
module Augmentor

using ColorTypes
using ColorTypes: AbstractGray
using ImageCore
using ImageTransformations
using ImageFiltering
using CoordinateTransformations
using Rotations
using Interpolations
using StaticArrays
using OffsetArrays
using IdentityRanges
using FileIO
using ShowItLikeYouBuildIt
using Compat
using Base.PermutedDimsArrays: PermutedDimsArray

export

    SplitChannels,
    CombineChannels,
    PermuteDims,
    Reshape,

    Rotate90,
    Rotate180,
    Rotate270,
    Rotate,

    ShearX,
    ShearY,

    FlipX,
    FlipY,

    Crop,
    CropNative,
    CropSize,
    CropRatio,
    RCropRatio,

    Resize,

    Scale,
    Zoom,

    CacheImage,
    NoOp,
    Either,

    ElasticDistortion,

    augment,

    testpattern

include("utils.jl")
include("types.jl")
include("operation.jl")

include("operations/channels.jl")

include("operations/noop.jl")
include("operations/cache.jl")
include("operations/rotation.jl")
include("operations/shear.jl")
include("operations/flip.jl")
include("operations/crop.jl")
include("operations/resize.jl")
include("operations/scale.jl")
include("operations/zoom.jl")
include("operations/either.jl")

include("distortionfields.jl")
include("distortedview.jl")
include("operations/distortion.jl")

include("pipeline.jl")
include("compile.jl")
include("augment.jl")

end # module
