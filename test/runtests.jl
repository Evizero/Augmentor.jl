using Augmentor, ImageCore, ImageTransformations, CoordinateTransformations, Interpolations, OffsetArrays, StaticArrays, ColorTypes, FixedPointNumbers, TestImages, IdentityRanges, Base.Test

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

square = Gray{N0f8}[0.1 0.2 0.3; 0.4 0.5 0.6; 0.7 0.6 0.9]
rect = Gray{N0f8}[0.1 0.2 0.3; 0.4 0.5 0.6]

tests = [
    "tst_utils.jl",
    "operations/tst_noop.jl",
    "operations/tst_rotation.jl",
    "operations/tst_crop.jl",
    "operations/tst_either.jl",
    "tst_operations.jl",
    "tst_pipeline.jl",
]

for t in tests
    @testset "$t" begin
        include(t)
    end
end
