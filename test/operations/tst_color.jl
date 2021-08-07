@testset "ColorJitter" begin
    @test ColorJitter <: Augmentor.ImageOperation

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
    @testset "_get_M" begin
        imgs = [testpattern()]#, camera]
        for img in imgs
            T = eltype(img)
            op = ColorJitter(1., 0., usemax=true)
            M = @inferred Augmentor._get_M(op, img)
            @test M == T(gamutmax(T)...)
            op = ColorJitter(1., 0., usemax=false)
            M = @inferred Augmentor._get_M(op, img)
            @test M == convert(T, mean(img))
        end
    end
    @testset "eager" begin
        @test Augmentor.supports_eager(ColorJitter)

        α = 0.2
        β = 0.1

        imgs = [testpattern(), camera]

        # M = mean value
        for img in imgs
            img = convert.(color_type(eltype(img)), img)
            ref = clamp01.(α .* img .+ β * mean(img))
            res = Augmentor.applyeager(ColorJitter(α, β, usemax=false), img)
            @test assess_psnr(res, ref) > 25
        end
        # M = maximum value
        for img in imgs
            img = convert.(color_type(eltype(img)), img)
            T = eltype(img)
            ref = clamp01.(α .* img .+ β * T(gamutmax(T)...))
            res = Augmentor.applyeager(ColorJitter(α, β, usemax=true), img)
            @test assess_psnr(res, ref) > 25
        end
    end
    @testset "lazy" begin
        @test Augmentor.supports_lazy(ColorJitter)

        α = 0.2
        β = 0.1

        imgs = [testpattern(), camera]

        # M = mean value
        for img in imgs
            img = convert.(color_type(eltype(img)), img)
            ref = clamp01.(α .* img .+ β * mean(img))
            res = Augmentor.applylazy(ColorJitter(α, β, usemax=false), img)
            @test assess_psnr(res, ref) > 25
        end
        # M = maximum value
        for img in imgs
            img = convert.(color_type(eltype(img)), img)
            T = eltype(img)
            ref = clamp01.(α .* img .+ β * T(gamutmax(T)...))
            res = Augmentor.applylazy(ColorJitter(α, β, usemax=true), img)
            @test assess_psnr(res, ref) > 25
        end
    end
end
