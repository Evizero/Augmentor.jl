using ImageCore, ImageFiltering
using Random
using ImageTransformations, CoordinateTransformations, Interpolations
using MLDataPattern
using OffsetArrays, StaticArrays, IdentityRanges, ComputationalResources
using ImageCore.MappedArrays
using ReferenceTests, Test, TestImages, ImageDistances, ImageQualityIndexes, Statistics

if isdefined(OffsetArrays, :IdOffsetRange)
    OffsetRange = OffsetArrays.IdOffsetRange
else
    OffsetRange = OffsetArrays.IdentityUnitRange
end

# check for ambiguities
refambs = detect_ambiguities(ImageTransformations, Base, Core)
using Augmentor
ambs = detect_ambiguities(Augmentor, ImageTransformations, Base, Core)
# The 3 is from plain_axes with a Tuple{} (so its spurious)
#@test Set(setdiff(ambs, refambs)) == Set{Tuple{Method,Method}}()
@test length(setdiff(ambs, refambs)) == 3

str_show(obj) = @io2str show(::IO, obj)
str_showcompact(obj) = @io2str show(IOContext(::IO, :compact=>true), obj)
str_showconst(obj) = @io2str Augmentor.showconstruction(::IO, obj)

camera = testimage("cameraman")
cameras = similar(camera, size(camera)..., 2)
copyto!(view(cameras,:,:,1), camera)
copyto!(view(cameras,:,:,2), camera)
square = Gray{N0f8}[0.1 0.2 0.3; 0.4 0.5 0.6; 0.7 0.6 0.9]
square2 = rand(Gray{N0f8}, 4, 4)
rect = Gray{N0f8}[0.1 0.2 0.3; 0.4 0.5 0.6]
checkers = Gray{N0f8}[1 0 1 0 1; 0 1 0 1 0; 1 0 1 0 1]
rgb_rect = rand(RGB{N0f8}, 2, 3)

tests = [
    "tst_compat.jl",
    "tst_utils.jl",
    "tst_wrapper.jl",
    "operations/tst_channels.jl",
    "operations/tst_dims.jl",
    "operations/tst_convert.jl",
    "operations/tst_mapfun.jl",
    "operations/tst_noop.jl",
    "operations/tst_cache.jl",
    "operations/tst_rotation.jl",
    "operations/tst_shear.jl",
    "operations/tst_flip.jl",
    "operations/tst_crop.jl",
    "operations/tst_resize.jl",
    "operations/tst_scale.jl",
    "operations/tst_zoom.jl",
    "operations/tst_distortions.jl",
    "operations/tst_either.jl",
    "operations/tst_blur.jl",
    "operations/tst_color.jl",
    "tst_operations.jl",
    "tst_pipeline.jl",
    "tst_augment.jl",
    "tst_augmentbatch.jl",
    "tst_distortedview.jl",
]

for t in tests
    @testset "$t" begin
        include(t)
    end
end
