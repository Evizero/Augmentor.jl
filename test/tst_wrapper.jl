@testset "Mask" begin
    @testset "unwrap" begin
        img = testpattern()
        m = Augmentor.Mask(img)
        @test Augmentor.unwrap(m) === img
    end
end
