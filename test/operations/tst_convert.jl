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
        @test_broken str_show(ConvertEltype(RGB)) == "Augmentor.ConvertEltype(RGB{Any})"
        @test_broken str_show(ConvertEltype(Gray{N0f8})) == "Augmentor.ConvertEltype(Gray{N0f8})"
        @test str_showconst(ConvertEltype(Float64)) == "ConvertEltype(Float64)"
        @test_broken str_showconst(ConvertEltype(RGB{N0f8})) == "ConvertEltype(RGB{N0f8})"
        @test str_showcompact(ConvertEltype(Float64)) == "Convert eltype to Float64"
        @test_broken str_showcompact(ConvertEltype(Gray)) == "Convert eltype to Gray{Any}"
    end
    @testset "eager" begin
        @test Augmentor.supports_eager(ConvertEltype) === true
        @test Augmentor.supports_eager(ConvertEltype{Float64}) === true
        let img = @inferred(Augmentor.applyeager(ConvertEltype(Gray), rgb_rect))
            @test typeof(img) == Array{Gray{N0f8},2}
            @test img == convert.(Gray, rgb_rect)
        end
        let img = @inferred(Augmentor.applyeager(ConvertEltype(Gray{Float32}), rgb_rect))
            @test typeof(img) == Array{Gray{Float32},2}
            @test img == convert.(Gray{Float32}, rgb_rect)
        end
        let img = @inferred(Augmentor.applyeager(ConvertEltype(Float32), checkers))
            @test typeof(img) == Array{Float32,2}
            @test img == convert(Array{Float32}, checkers)
        end
        let img = @inferred(Augmentor.applyeager(ConvertEltype(RGB), checkers))
            @test typeof(img) == Array{RGB{N0f8},2}
            @test img == convert.(RGB, checkers)
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
        @test Augmentor.supports_lazy(ConvertEltype{Float64}) === true
        @test @inferred(Augmentor.supports_lazy(typeof(ConvertEltype(Gray)))) === true
        let img = @inferred(Augmentor.applylazy(ConvertEltype(Gray), rgb_rect))
            @test typeof(img) <: ReadonlyMappedArray{Gray{N0f8},2}
            @test img == convert.(Gray, rgb_rect)
        end
        let img = @inferred(Augmentor.applylazy(ConvertEltype(Gray{Float32}), rgb_rect))
            @test typeof(img) <: ReadonlyMappedArray{Gray{Float32},2}
            @test img == convert.(Gray{Float32}, rgb_rect)
        end
        let img = @inferred(Augmentor.applylazy(ConvertEltype(Float32), checkers))
            @test typeof(img) <: ReadonlyMappedArray{Float32,2}
            @test img == convert(Array{Float32}, checkers)
        end
        let img = @inferred(Augmentor.applylazy(ConvertEltype(RGB), checkers))
            @test typeof(img) <: ReadonlyMappedArray{RGB{N0f8},2}
            @test img == convert.(RGB, checkers)
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
