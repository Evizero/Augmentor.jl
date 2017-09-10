# Things that needs to be tested
# [x] Utility functions work properly and type stable
# [x] Individual operations do what they should
# [x] Individual operations are always type stable
# [x] Lazy Either works correctly and type stable
# [x] Operations accept AbstractArray as input (esp. Array and SubArray)

using ImageCore, ImageFiltering, ImageTransformations, CoordinateTransformations, Interpolations, OffsetArrays, StaticArrays, ColorTypes, FixedPointNumbers, TestImages, IdentityRanges, MappedArrays, ComputationalResources, MLDataPattern, ReferenceTests, Base.Test
using ImageInTerminal

# check for ambiguities
refambs = detect_ambiguities(ImageTransformations, Base, Core)
using Augmentor
ambs = detect_ambiguities(Augmentor, ImageTransformations, Base, Core)
@test length(setdiff(ambs, refambs)) == 0

function str_show(obj)
    io = IOBuffer()
    Base.show(io, obj)
    readstring(seek(io, 0))
end

function str_showcompact(obj)
    io = IOBuffer()
    Base.showcompact(io, obj)
    readstring(seek(io, 0))
end

function str_showconst(obj)
    io = IOBuffer()
    Augmentor.showconstruction(io, obj)
    readstring(seek(io, 0))
end

camera = testimage("cameraman")
cameras = similar(camera, size(camera)..., 2)
copy!(view(cameras,:,:,1), camera)
copy!(view(cameras,:,:,2), camera)
square = Gray{N0f8}[0.1 0.2 0.3; 0.4 0.5 0.6; 0.7 0.6 0.9]
square2 = rand(Gray{N0f8}, 4, 4)
rect = Gray{N0f8}[0.1 0.2 0.3; 0.4 0.5 0.6]
checkers = Gray{N0f8}[1 0 1 0 1; 0 1 0 1 0; 1 0 1 0 1]
rgb_rect = rand(RGB{N0f8}, 2, 3)

tests = [
    "tst_utils.jl",
    "operations/tst_channels.jl",
    "operations/tst_convert.jl",
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
