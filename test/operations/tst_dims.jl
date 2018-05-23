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
        f = (img) -> permutedims(img, (2,1))
        imgs = [
            (rect),
            (Augmentor.prepareaffine(rect)),
            (OffsetArray(rect, -2, -1)),
            (view(rect, IdentityRange(1:2), IdentityRange(1:3))),
        ]
        @testset "single image" begin
            for img_in in imgs
                img_out = f(img_in)
                @test_throws MethodError Augmentor.applyeager(PermuteDims(3,2,1), img_in)
                res = @inferred(Augmentor.applyeager(PermuteDims(2,1), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
            end
        end
        @testset "multiple images" begin
            for img_in1 in imgs, img_in2 in imgs
                img_out1 = f(img_in1)
                img_out2 = f(img_in2)
                img_in = (img_in1, img_in2)
                img_out = (img_out1, img_out2)
                @test_throws MethodError Augmentor.applyeager(PermuteDims(3,2,1), img_in)
                res = @inferred(Augmentor.applyeager(PermuteDims(2,1), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
            end
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
        f = (img) -> permuteddimsview(img, (2,1))
        imgs = [
            (rect),
            (Augmentor.prepareaffine(rect)),
            (OffsetArray(rect, -2, -1)),
            (view(rect, IdentityRange(1:2), IdentityRange(1:3))),
        ]
        @testset "single image" begin
            for img_in in imgs
                img_out = f(img_in)
                @test_throws MethodError Augmentor.applylazy(PermuteDims(3,2,1), img_in)
                res = @inferred(Augmentor.applylazy(PermuteDims(2,1), img_in))
                @test res == img_out
                @test res == Augmentor.applyeager(PermuteDims(2,1), img_in)
                @test typeof(res) == typeof(img_out)
            end
        end
        @testset "multiple images" begin
            for img_in1 in imgs, img_in2 in imgs
                img_out1 = f(img_in1)
                img_out2 = f(img_in2)
                img_in = (img_in1, img_in2)
                img_out = (img_out1, img_out2)
                @test_throws MethodError Augmentor.applylazy(PermuteDims(3,2,1), img_in)
                res = @inferred(Augmentor.applylazy(PermuteDims(2,1), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
            end
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
        imgo = Augmentor.plain_array(reshape(rect, (3,2,1)))
        imgs = [
            (rect),
            (Augmentor.prepareaffine(rect)),
            (OffsetArray(rect, -2, -1)),
            (view(rect, IdentityRange(1:2), IdentityRange(1:3))),
        ]
        @testset "single image" begin
            for img_in in imgs
                img_out = imgo
                res = @inferred(Augmentor.applyeager(Reshape(3,2,1), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
            end
        end
        @testset "multiple images" begin
            for img_in1 in imgs, img_in2 in imgs
                img_out1 = imgo
                img_out2 = imgo
                img_in = (img_in1, img_in2)
                img_out = (img_out1, img_out2)
                res = @inferred(Augmentor.applyeager(Reshape(3,2,1), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
            end
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
        imgs = [
            (rect),
            (Augmentor.prepareaffine(rect)),
            (OffsetArray(rect, -2, -1)),
            (view(rect, IdentityRange(1:2), IdentityRange(1:3))),
        ]
        @testset "single image" begin
            for img_in in imgs
                img_out = reshape(Augmentor.plain_indices(img_in), (3,2,1))
                res = @inferred(Augmentor.applylazy(Reshape(3,2,1), img_in))
                @test res == Augmentor.applyeager(Reshape(3,2,1), img_in)
                @test res == img_out
                @test typeof(res) == typeof(img_out)
            end
        end
        @testset "multiple images" begin
            for img_in1 in imgs, img_in2 in imgs
                img_out1 = reshape(Augmentor.plain_indices(img_in1), (3,2,1))
                img_out2 = reshape(Augmentor.plain_indices(img_in2), (3,2,1))
                img_in = (img_in1, img_in2)
                img_out = (img_out1, img_out2)
                res = @inferred(Augmentor.applylazy(Reshape(3,2,1), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
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
