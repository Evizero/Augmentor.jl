using Augmentor
using Base.Test

tests = [
    "tst_show.jl",
]

for t in tests
    @testset "$t" begin
        include(t)
    end
end
