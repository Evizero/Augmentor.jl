@testset "ConvertEltype" begin
    @test (ConvertEltype <: Augmentor.AffineOperation) == false
    @test (ConvertEltype <: Augmentor.ImageOperation) == false
    @test (ConvertEltype <: Augmentor.Operation) == true

    @testset "constructor" begin
        @test_throws MethodError ConvertEltype()
        @test typeof(@inferred(ConvertEltype(Float64))) <: ConvertEltype <: Augmentor.Operation
        @test typeof(@inferred(ConvertEltype(RGB))) <: ConvertEltype <: Augmentor.Operation
        @test typeof(@inferred(ConvertEltype(RGB{N0f8}))) <: ConvertEltype <: Augmentor.Operation
        @test str_show(ConvertEltype(Float64)) == "Augmentor.ConvertEltype(Float64)"
        @test str_show(ConvertEltype(RGB)) == "Augmentor.ConvertEltype(RGB{Any})"
        @test str_show(ConvertEltype(Gray{N0f8})) == "Augmentor.ConvertEltype(Gray{N0f8})"
        @test str_showconst(ConvertEltype(Float64)) == "ConvertEltype(Float64)"
        @test str_showconst(ConvertEltype(RGB{N0f8})) == "ConvertEltype(RGB{N0f8})"
        @test str_showcompact(ConvertEltype(Float64)) == "Convert eltype to Float64"
        @test str_showcompact(ConvertEltype(Gray)) == "Convert eltype to Gray{Any}"
    end
    @testset "eager" begin
        @test Augmentor.supports_eager(ConvertEltype) === true
        @test Augmentor.supports_eager(ConvertEltype{Float64}) === true
        res1 = convert(Array{Gray{Float32}}, rect)
        res1a = OffsetArray(res1, 0, 0)
        res1b = OffsetArray(res1, -2, -1)
        imgs = [
            (Float32, rect, Float32.(res1)),
            (Float32, OffsetArray(rect, -2, -1), Float32.(res1b)),
            (Gray{Float32}, rect, res1),
            (Gray{Float32}, Float64.(rect), res1),
            (Gray{Float32}, reshape(view(rect,:,:), 2,3), res1),
            (Gray{Float32}, RGB{N0f8}.(rect), res1),
            (Gray{Float32}, Augmentor.prepareaffine(rect), res1a),
            (Gray{Float32}, OffsetArray(rect, -2, -1), res1b),
            (Gray{Float32}, view(rect, IdentityRange(1:2), IdentityRange(1:3)), res1a),
            (RGB{Float32}, rect, RGB{Float32}.(res1)),
            (RGB{Float32}, OffsetArray(rect, -2, -1), RGB{Float32}.(res1b)),
        ]
        @testset "single image" begin
            for (T, img_in, img_out) in imgs
                res = @inferred(Augmentor.applyeager(ConvertEltype(T), img_in))
                @test res ≈ img_out
                @test typeof(res) == typeof(img_out)
            end
        end
    end
    @testset "affine" begin
        @test Augmentor.supports_affine(ConvertEltype) === false
    end
    @testset "affineview" begin
        @test Augmentor.supports_affineview(ConvertEltype) === false
    end
    @testset "lazy" begin
        @test Augmentor.supports_lazy(ConvertEltype) === true
        @test @inferred(Augmentor.supports_lazy(ConvertEltype{Float64})) === true
        @test @inferred(Augmentor.supports_lazy(typeof(ConvertEltype(Gray)))) === true
        @test @inferred(Augmentor.supports_lazy(typeof(ConvertEltype(Gray{N0f8})))) === true
        let img = @inferred(Augmentor.applylazy(ConvertEltype(Gray{Float32}), OffsetArray(rect,-2,-1)))
            @test parent(parent(img)) === rect
            @test typeof(img) <: ReadonlyMappedArray{Gray{Float32},2}
            @test indices(img) === (-1:0, 0:2)
            @test img[0,0] isa Gray{Float32}
            @test collect(img) == convert.(Gray{Float32}, rect)
        end
        let img = @inferred(Augmentor.applylazy(ConvertEltype(Gray{Float32}), Augmentor.prepareaffine(rect)))
            @test parent(parent(parent(parent(img)))) === rect
            @test typeof(img) <: ReadonlyMappedArray{Gray{Float32},2}
            @test indices(img) === (1:2, 1:3)
            @test img[1,1] isa Gray{Float32}
            @test collect(img) == convert.(Gray{Float32}, rect)
        end
        let img = @inferred(Augmentor.applylazy(ConvertEltype(Gray{Float32}), view(rect, IdentityRange(1:2), IdentityRange(1:3))))
            @test parent(parent(img)) === rect
            @test typeof(img) <: ReadonlyMappedArray{Gray{Float32},2}
            @test indices(img) === (1:2, 1:3)
            @test img[1,1] isa Gray{Float32}
            @test collect(img) == convert.(Gray{Float32}, rect)
        end
        let img = @inferred(Augmentor.applylazy(ConvertEltype(Gray{Float32}), rgb_rect))
            @test parent(img) === rgb_rect
            @test indices(img) === (Base.OneTo(2), Base.OneTo(3))
            @test typeof(img) <: ReadonlyMappedArray{Gray{Float32},2}
            @test img == convert.(Gray{Float32}, rgb_rect)
        end
        let img = @inferred(Augmentor.applylazy(ConvertEltype(Float32), checkers))
            @test parent(img) === checkers
            @test indices(img) === (Base.OneTo(3), Base.OneTo(5))
            @test typeof(img) <: ReadonlyMappedArray{Float32,2}
            @test img == convert(Array{Float32}, checkers)
        end
        let img = @inferred(Augmentor.applylazy(ConvertEltype(RGB{N0f8}), checkers))
            @test parent(img) === checkers
            @test typeof(img) <: ReadonlyMappedArray{RGB{N0f8},2}
            @test img == convert.(RGB, checkers)
        end
        let img = @inferred(Augmentor.applylazy(ConvertEltype(RGB{Float64}), checkers))
            @test parent(img) === checkers
            @test typeof(img) <: ReadonlyMappedArray{RGB{Float64},2}
            @test img == convert.(RGB{Float64}, checkers)
        end
    end
    @testset "view" begin
        @test Augmentor.supports_view(ConvertEltype) === false
    end
    @testset "stepview" begin
        @test Augmentor.supports_stepview(ConvertEltype) === false
    end
    @testset "permute" begin
        @test Augmentor.supports_permute(ConvertEltype) === false
    end
end
