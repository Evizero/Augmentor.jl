using Augmentor, ImageCore, ImageTransformations, CoordinateTransformations, OffsetArrays, StaticArrays, ColorTypes, FixedPointNumbers, TestImages, IdentityRanges, Base.Test

tests = [
    "tst_utils.jl",
    "tst_operations.jl",
    "tst_pipeline.jl",
]

for t in tests
    @testset "$t" begin
        include(t)
    end
end
