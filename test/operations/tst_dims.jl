@testset "PermuteDims" begin
    @test (PermuteDims <: Augmentor.AffineOperation) == false
    @test (PermuteDims <: Augmentor.ImageOperation) == false
    @test (PermuteDims <: Augmentor.Operation) == true

    @testset "constructor" begin
        @test_throws MethodError PermuteDims()
        @test_throws MethodError PermuteDims(())
        @test_throws MethodError PermuteDims(Float64)
        @test_throws ArgumentError PermuteDims((2,2))
        @test_throws ArgumentError PermuteDims(2,2)
        @test typeof(PermuteDims(1,2)) <: PermuteDims{2} <: Augmentor.Operation
        @test typeof(PermuteDims((1,2))) <: PermuteDims{2} <: Augmentor.Operation
        @test typeof(PermuteDims(1)) <: PermuteDims{1} <: Augmentor.Operation
        @test typeof(PermuteDims((1,))) <: PermuteDims{1} <: Augmentor.Operation
        @test typeof(PermuteDims((1,2))) <: PermuteDims{2} <: Augmentor.Operation
        @test typeof(PermuteDims((3,1,2))) <: PermuteDims{3} <: Augmentor.Operation
        @test str_show(PermuteDims((1,))) == "Augmentor.PermuteDims((1,))"
        @test str_show(PermuteDims((1,2))) == "Augmentor.PermuteDims((1, 2))"
        @test str_showconst(PermuteDims((1,3,2))) == "PermuteDims(1, 3, 2)"
        @test str_showcompact(PermuteDims((3,2,1))) == "Permute dimension order to (3, 2, 1)"
    end
    @testset "eager" begin
        @test Augmentor.supports_eager(PermuteDims) === true
        @test @inferred(Augmentor.supports_eager(typeof(PermuteDims(2,1)))) === true
        for img in (Augmentor.prepareaffine(rect), rect, OffsetArray(rect, -2, -1), view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test_throws MethodError Augmentor.applyeager(PermuteDims(3,2,1), img)
            @test @inferred(Augmentor.applyeager(PermuteDims(2,1), img)) == permutedims(img, (2,1))
            @test typeof(Augmentor.applyeager(PermuteDims(2,1), img)) == typeof(permutedims(img, (2,1)))
        end
    end
    @testset "affine" begin
        @test Augmentor.supports_affine(PermuteDims) === false
    end
    @testset "affineview" begin
        @test Augmentor.supports_affineview(PermuteDims) === false
    end
    @testset "lazy" begin
        @test Augmentor.supports_lazy(PermuteDims) === true
        @test @inferred(Augmentor.supports_lazy(typeof(PermuteDims(2,1)))) === true
        for img in (Augmentor.prepareaffine(rect), rect, OffsetArray(rect, -2, -1), view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test_throws MethodError Augmentor.applylazy(PermuteDims(3,2,1), img)
            @test @inferred(Augmentor.applylazy(PermuteDims(2,1), img)) === permuteddimsview(img, (2,1))
        end
    end
    @testset "view" begin
        @test Augmentor.supports_view(PermuteDims) === false
    end
    @testset "stepview" begin
        @test Augmentor.supports_stepview(PermuteDims) === false
    end
    @testset "permute" begin
        @test Augmentor.supports_permute(PermuteDims) === false
    end
end

# --------------------------------------------------------------------

@testset "Reshape" begin
    @test (Reshape <: Augmentor.AffineOperation) == false
    @test (Reshape <: Augmentor.ImageOperation) == false
    @test (Reshape <: Augmentor.Operation) == true

    @testset "constructor" begin
        @test_throws MethodError Reshape()
        @test_throws MethodError Reshape(())
        @test_throws MethodError Reshape(Float64)
        @test_throws MethodError Reshape(1.,2.)
        @test typeof(Reshape(2,2)) <: Reshape{2} <: Augmentor.Operation
        @test typeof(Reshape(1,2)) <: Reshape{2} <: Augmentor.Operation
        @test typeof(Reshape((1,2))) <: Reshape{2} <: Augmentor.Operation
        @test typeof(Reshape(1)) <: Reshape{1} <: Augmentor.Operation
        @test typeof(Reshape((1,))) <: Reshape{1} <: Augmentor.Operation
        @test typeof(Reshape((1,2))) <: Reshape{2} <: Augmentor.Operation
        @test typeof(Reshape((3,1,2))) <: Reshape{3} <: Augmentor.Operation
        @test str_show(Reshape((1,))) == "Augmentor.Reshape{1}((1,))"
        @test str_show(Reshape((1,2))) == "Augmentor.Reshape{2}((1, 2))"
        @test str_showconst(Reshape((1,3,2))) == "Reshape(1, 3, 2)"
        @test str_showcompact(Reshape((3,2,1))) == "Reshape array to 3×2×1"
        @test str_showcompact(Reshape(10)) == "Reshape array to 10-element vector"
    end
    @testset "eager" begin
        @test Augmentor.supports_eager(Reshape) === false
        @test @inferred(Augmentor.supports_eager(typeof(Reshape(2,1)))) === false
        # FIXME: reintroduce Augmentor.prepareaffine(rect) in 0.6
        for img in (rect, OffsetArray(rect, -2, -1), view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applyeager(Reshape(3,2,1), img)) == reshape(img, (3,2,1))
            @test typeof(Augmentor.applyeager(Reshape(3,2,1), img)) <: Array{Gray{N0f8}}
        end
    end
    @testset "affine" begin
        @test Augmentor.supports_affine(Reshape) === false
    end
    @testset "affineview" begin
        @test Augmentor.supports_affineview(Reshape) === false
    end
    @testset "lazy" begin
        @test Augmentor.supports_lazy(Reshape) === true
        @test @inferred(Augmentor.supports_lazy(typeof(Reshape(2,1)))) === true
        # FIXME: reintroduce Augmentor.prepareaffine(rect) in 0.6
        for img in (rect, OffsetArray(rect, -2, -1), view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applylazy(Reshape(3,2,1), img)) == reshape(img, (3,2,1))
            if typeof(img) <: Array
                @test typeof(Augmentor.applylazy(Reshape(3,2,1), img)) <: Array{Gray{N0f8}}
            else
                @test typeof(Augmentor.applylazy(Reshape(3,2,1), img)) <: Base.ReshapedArray
            end
        end
    end
    @testset "view" begin
        @test Augmentor.supports_view(Reshape) === false
    end
    @testset "stepview" begin
        @test Augmentor.supports_stepview(Reshape) === false
    end
    @testset "permute" begin
        @test Augmentor.supports_permute(Reshape) === false
    end
end
