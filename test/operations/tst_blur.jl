import ImageFiltering: imfilter, KernelFactors.gaussian

@testset "GaussianBlur" begin
    @testset "constructor" begin
        @test_throws ArgumentError GaussianBlur(0, 1)
        @test_throws ArgumentError GaussianBlur(3, 0)
        @test_throws ArgumentError GaussianBlur([1, 3], 0)
        @test_throws ArgumentError GaussianBlur([1, 0], 1)
        @test_throws ArgumentError GaussianBlur(3, -1:1)
    end
    @testset "randparam" begin
        img = testpattern()
        ks = [3, 1:2:5, [1, 3, 5]]
        σs = [1, 1:0.1:2, [1, 2]]
        for k in ks, σ in σs
            op = GaussianBlur(k, σ)
            p = @inferred Augmentor.randparam(op, img)
            @test p[1] in k
            @test p[2] in σ
        end
    end
    @testset "eager" begin
        @test Augmentor.supports_eager(GaussianBlur)

        k = 3
        σ = 3.2

        imgs = [testpattern(), camera]

        for img in imgs
            ref = imfilter(img, gaussian((σ, σ), (k, k)))
            res = Augmentor.applyeager(GaussianBlur(k, σ), img)
            @test ref == res
        end
    end
end
