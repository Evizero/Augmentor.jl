module Augmentor

using ImageCore
using ImageCore.MappedArrays
using ImageTransformations
using ImageFiltering
using CoordinateTransformations
using Rotations
using Interpolations
using StaticArrays
using IdentityRanges
using MLDataPattern
using ComputationalResources
using FileIO
using Base.PermutedDimsArrays: PermutedDimsArray
using LinearAlgebra
using OffsetArrays

# axes(::OffsetArray) changes from Base.Slice to Base.IdentityUnitRange in julia 1.1
# https://github.com/JuliaArrays/OffsetArrays.jl/pull/62
# TODO: switch to Base.IdentityUnitRange when we decide to drop 1.0 compatibility
using OffsetArrays: IdentityUnitRange

using InteractiveUtils: methodswith

export

    CPU1,
    CPUThreads,

    Gray,
    RGB,

    SplitChannels,
    CombineChannels,
    PermuteDims,
    Reshape,

    ConvertEltype,
    MapFun,
    AggregateThenMapFun,

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
    RCropSize,

    Resize,

    Scale,
    Zoom,

    CacheImage,
    NoOp,
    Either,

    ElasticDistortion,

    AdjustContrastBrightness,
    GaussianBlur,

    augment,
    augment!,
    augmentbatch!,

    testpattern

include("compat.jl")
include("utils.jl")
include("types.jl")
include("operation.jl")

include("operations/channels.jl")
include("operations/dims.jl")
include("operations/convert.jl")
include("operations/mapfun.jl")

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
include("operations/brightness.jl")
include("operations/blur.jl")

include("distortionfields.jl")
include("distortedview.jl")
include("operations/distortion.jl")

include("pipeline.jl")
include("codegen.jl")
include("augment.jl")
include("augmentbatch.jl")

function __init__()
    if VERSION < v"1.3"
        # see compat.jl
        rand_mutex[] = Threads.Mutex()
    end
end

end # module
