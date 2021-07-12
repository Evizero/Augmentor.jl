@testset "ColorJitter" begin
    @testset "constructor" begin
        @test_throws ArgumentError ColorJitter(1., 3.0:2.0)
        @test_throws ArgumentError ColorJitter(5.0:3.0, 1.)
    end
    @testset "randparam" begin
        img = testpattern()
        αs = [3.0, 1.0:0.2:5.0, [1.0, 3.0, 5.0]]
        βs = [1.0, 1.0:0.1:2.0, [1.0, 2.0]]
        for α in αs, β in βs
            op = ColorJitter(α, β)
            p = @inferred Augmentor.randparam(op, img)
            @test p[1] in α
            @test p[2] in β
        end
    end
    @testset "eager" begin
        @test Augmentor.supports_eager(ColorJitter)

        α = 0.2
        β = 0.1

        imgs = [testpattern(), camera]

        # M = mean value
        for img in imgs
            ref = clamp01.(α .* img .+ β * mean(img))
            res = Augmentor.applyeager(ColorJitter(α, β, usemax=false), img)
            @test ref == res
        end
        # M = maximum value
        for img in imgs
            ref = clamp01.(α .* img .+ β * gamutmax(eltype(img)))
            res = Augmentor.applyeager(ColorJitter(α, β), img)
            @test ref == res
        end
    end
    @testset "lazy" begin
        @test Augmentor.supports_lazy(ColorJitter)

        α = 0.2
        β = 0.1

        imgs = [testpattern(), camera]

        # M = mean value
        for img in imgs
            ref = clamp01.(α .* img .+ β * mean(img))
            res = Augmentor.applylazy(ColorJitter(α, β, usemax=false), img)
            @test ref == res
        end
        # M = maximum value
        for img in imgs
            ref = clamp01.(α .* img .+ β * gamutmax(eltype(img)))
            res = Augmentor.applylazy(ColorJitter(α, β), img)
            @test ref == res
        end
    end
end
