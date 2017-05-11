using ImageCore, ImageTransformations, CoordinateTransformations, Interpolations, OffsetArrays, StaticArrays, ColorTypes, FixedPointNumbers, TestImages, IdentityRanges, Base.Test
using ImageInTerminal

# check for ambiguities
refambs = detect_ambiguities(ImageTransformations, Base, Core)
using Augmentor
ambs = detect_ambiguities(Augmentor, ImageTransformations, Base, Core)
@test isempty(setdiff(ambs, refambs))

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

SPACE = VERSION < v"0.6.0-dev.2505" ? "" : " " # julia PR #20288

camera = testimage("cameraman")
square = Gray{N0f8}[0.1 0.2 0.3; 0.4 0.5 0.6; 0.7 0.6 0.9]
rect = Gray{N0f8}[0.1 0.2 0.3; 0.4 0.5 0.6]

tests = [
    "tst_utils.jl",
    "operations/tst_noop.jl",
    "operations/tst_rotation.jl",
    "operations/tst_flip.jl",
    "operations/tst_crop.jl",
    "operations/tst_resize.jl",
    "operations/tst_scale.jl",
    "operations/tst_zoom.jl",
    "operations/tst_either.jl",
    "tst_operations.jl",
    "tst_pipeline.jl",
    "tst_augment.jl",
]

for t in tests
    @testset "$t" begin
        include(t)
    end
end
