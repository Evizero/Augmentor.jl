@testset "FlipX" begin
    @test typeof(@inferred(FlipX())) <: FlipX <: Augmentor.AffineOperation
    @testset "constructor" begin
        @test @inferred(FlipX(0.7)) === Either(FlipX(), 0.7)
        @test str_show(FlipX()) == "Augmentor.FlipX()"
        @test str_showconst(FlipX()) == "FlipX()"
        @test str_showcompact(FlipX()) == "Flip the X axis"
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(FlipX(), nothing)
        @test Augmentor.supports_eager(FlipX) === true
        res1 = flipdim(rect, 2)
        imgs = [
            (rect, res1),
            (Augmentor.prepareaffine(rect), res1),
            (OffsetArray(rect, -2, -1), res1),
            (view(rect, IdentityRange(1:2), IdentityRange(1:3)), res1),
        ]
        @testset "single image" begin
            for (img_in, img_out) in imgs
                res = @inferred(Augmentor.applyeager(FlipX(), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
            end
        end
        @testset "multiple images" begin
            for (img_in1, img_out1) in imgs, (img_in2, img_out2) in imgs
                img_in = (img_in1, img_in2)
                img_out = (img_out1, img_out2)
                res = @inferred(Augmentor.applyeager(FlipX(), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
            end
        end
    end
    @testset "affine" begin
        @test Augmentor.supports_affine(FlipX) === true
        @test_throws MethodError Augmentor.applyaffine(FlipX(), nothing)
        @test @inferred(Augmentor.toaffinemap(FlipX(), rect)) ≈ AffineMap([1. 0.; 0. -1.], [0.0,4.0])
        @testset "single image" begin
            wv = @inferred Augmentor.applyaffine(FlipX(), Augmentor.prepareaffine(square))
            @test parent(wv).itp.coefs === square
            @test wv == flipdim(square,2)
            @test typeof(wv) <: InvWarpedView{eltype(square),2}
        end
        @testset "multiple images" begin
            img_in = Augmentor.prepareaffine.((rgb_rect, square))
            res1, res2 = @inferred(Augmentor.applyaffine(FlipX(), img_in))
            # make sure affine map is specific to image
            @test res1 == flipdim(rgb_rect, 2)
            @test res2 == flipdim(square, 2)
            @test typeof(res1) <: InvWarpedView{eltype(rgb_rect),2}
            @test typeof(res2) <: InvWarpedView{eltype(square),2}
        end
    end
    @testset "affineview" begin
        @test Augmentor.supports_affineview(FlipX) === true
        @test_throws MethodError Augmentor.applyaffineview(FlipX(), nothing)
        wv = @inferred Augmentor.applyaffineview(FlipX(), Augmentor.prepareaffine(square))
        @test typeof(wv) <: SubArray{eltype(square),2}
        @test typeof(parent(wv)) <: InvWarpedView
        @test parent(parent(wv)).itp.coefs === square
        @test wv == flipdim(square,2)
    end
    @testset "lazy" begin
        @test Augmentor.supports_lazy(FlipX) === true
        @testset "single image" begin
            v = @inferred Augmentor.applylazy(FlipX(), rect)
            @test v === view(rect, 1:1:2, 3:-1:1)
            @test v == flipdim(rect,2)
            @test typeof(v) <: SubArray
            wv = @inferred Augmentor.applylazy(FlipX(), Augmentor.prepareaffine(square))
            @test parent(wv).itp.coefs === square
            @test wv == flipdim(square,2)
            @test typeof(wv) <: InvWarpedView{eltype(square),2}
        end
        @testset "multiple images" begin
            img_in = (rgb_rect, square)
            res1, res2 = @inferred(Augmentor.applylazy(FlipX(), img_in))
            @test res1 == flipdim(rgb_rect, 2)
            @test res2 == flipdim(square, 2)
            @test typeof(res1) <: SubArray{eltype(rgb_rect),2}
            @test typeof(res2) <: SubArray{eltype(square),2}
        end
    end
    @testset "view" begin
        @test Augmentor.supports_view(FlipX) === false
    end
    @testset "stepview" begin
        @test Augmentor.supports_stepview(FlipX) === true
        v = @inferred Augmentor.applylazy(FlipX(), rect)
        @test v === view(rect, 1:1:2, 3:-1:1)
        @test v == flipdim(rect,2)
        @test typeof(v) <: SubArray
    end
    @testset "permute" begin
        @test Augmentor.supports_permute(FlipX) === false
    end
end

# --------------------------------------------------------------------

@testset "FlipY" begin
    @test typeof(@inferred(FlipY())) <: FlipY <: Augmentor.AffineOperation
    @testset "constructor" begin
        @test @inferred(FlipY(0.7)) === Either(FlipY(), 0.7)
        @test str_show(FlipY()) == "Augmentor.FlipY()"
        @test str_showconst(FlipY()) == "FlipY()"
        @test str_showcompact(FlipY()) == "Flip the Y axis"
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(FlipY(), nothing)
        @test Augmentor.supports_eager(FlipY) === true
        res1 = flipdim(rect, 1)
        imgs = [
            (rect, res1),
            (Augmentor.prepareaffine(rect), res1),
            (OffsetArray(rect, -2, -1), res1),
            (view(rect, IdentityRange(1:2), IdentityRange(1:3)), res1),
        ]
        @testset "single image" begin
            for (img_in, img_out) in imgs
                res = @inferred(Augmentor.applyeager(FlipY(), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
            end
        end
        @testset "multiple images" begin
            for (img_in1, img_out1) in imgs, (img_in2, img_out2) in imgs
                img_in = (img_in1, img_in2)
                img_out = (img_out1, img_out2)
                res = @inferred(Augmentor.applyeager(FlipY(), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
            end
        end
    end
    @testset "affine" begin
        @test Augmentor.supports_affine(FlipY) === true
        @test_throws MethodError Augmentor.applyaffine(FlipY(), nothing)
        @test @inferred(Augmentor.toaffinemap(FlipY(), rect)) ≈ AffineMap([-1. 0.; 0. 1.], [3.0,0.0])
        @testset "single image" begin
            wv = @inferred Augmentor.applyaffine(FlipY(), Augmentor.prepareaffine(square))
            @test parent(wv).itp.coefs === square
            @test wv == flipdim(square,1)
            @test typeof(wv) <: InvWarpedView{eltype(square),2}
        end
        @testset "multiple images" begin
            img_in = Augmentor.prepareaffine.((rgb_rect, square))
            res1, res2 = @inferred(Augmentor.applyaffine(FlipY(), img_in))
            # make sure affine map is specific to image
            @test res1 == flipdim(rgb_rect, 1)
            @test res2 == flipdim(square, 1)
            @test typeof(res1) <: InvWarpedView{eltype(rgb_rect),2}
            @test typeof(res2) <: InvWarpedView{eltype(square),2}
        end
    end
    @testset "affineview" begin
        @test Augmentor.supports_affineview(FlipY) === true
        @test_throws MethodError Augmentor.applyaffineview(FlipY(), nothing)
        wv = @inferred Augmentor.applyaffineview(FlipY(), Augmentor.prepareaffine(square))
        @test typeof(wv) <: SubArray{eltype(square),2}
        @test typeof(parent(wv)) <: InvWarpedView
        @test parent(parent(wv)).itp.coefs === square
        @test wv == flipdim(square,1)
    end
    @testset "lazy" begin
        @test Augmentor.supports_lazy(FlipY) === true
        @testset "single image" begin
            v = @inferred Augmentor.applylazy(FlipY(), rect)
            @test v === view(rect, 2:-1:1, 1:1:3)
            @test v == flipdim(rect,1)
            @test typeof(v) <: SubArray
            wv = @inferred Augmentor.applylazy(FlipY(), Augmentor.prepareaffine(square))
            @test parent(wv).itp.coefs === square
            @test wv == flipdim(square,1)
            @test typeof(wv) <: InvWarpedView{eltype(square),2}
        end
        @testset "multiple images" begin
            img_in = (rgb_rect, square)
            res1, res2 = @inferred(Augmentor.applylazy(FlipY(), img_in))
            @test res1 == flipdim(rgb_rect, 1)
            @test res2 == flipdim(square, 1)
            @test typeof(res1) <: SubArray{eltype(rgb_rect),2}
            @test typeof(res2) <: SubArray{eltype(square),2}
        end
    end
    @testset "view" begin
        @test Augmentor.supports_view(FlipY) === false
    end
    @testset "stepview" begin
        @test Augmentor.supports_stepview(FlipY) === true
        v = @inferred Augmentor.applylazy(FlipY(), rect)
        @test v === view(rect, 2:-1:1, 1:1:3)
        @test v == flipdim(rect,1)
        @test typeof(v) <: SubArray
    end
    @testset "permute" begin
        @test Augmentor.supports_permute(FlipY) === false
    end
end
