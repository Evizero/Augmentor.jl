@testset "Resize" begin
    @test (Resize <: Augmentor.AffineOperation) == false
    @test typeof(@inferred(Resize())) <: Resize <: Augmentor.ImageOperation
    @testset "constructor" begin
        @test_throws MethodError Resize(())
        @test_throws MethodError Resize(1.,2.)
        @test_throws MethodError Resize(:a)
        @test_throws MethodError Resize([:a])
        @test_throws ArgumentError Resize(-1)
        @test_throws ArgumentError Resize(0,2)
        op = @inferred(Resize(10))
        @test str_show(op) == "Augmentor.Resize{1}((10,))"
        @test str_showconst(op) == "Resize(10)"
        @test str_showcompact(op) == "Resize to (10,)"
        op = @inferred(Resize(20,30))
        @test op === Resize(width=30, height=20)
        @test op.size == (20,30)
        @test str_show(op) == "Augmentor.Resize{2}((20, 30))"
        @test str_showconst(op) == "Resize(20, 30)"
        @test str_showcompact(op) == "Resize to 20×30"
        op = @inferred(Resize(20,30,40))
        @test op === @inferred(Resize((20,30,40)))
        @test op === @inferred(Resize{3}((20,30,40)))
        @test op.size == (20,30,40)
        @test str_show(op) == "Augmentor.Resize{3}((20, 30, 40))"
        @test str_showconst(op) == "Resize(20, 30, 40)"
        @test str_showcompact(op) == "Resize to (20, 30, 40)"
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(Resize(10,10), nothing)
        @test Augmentor.supports_eager(Resize) === true
        ref = Gray{N0f8}[0.624 0.686 0.733 0.686 0.612; 0.667 0.055 0.71 0.675 0.596; 0.639 0.043 0.227 0.631 0.604; 0.569 0.031 0.518 0.553 0.529; 0.392 0.145 0.392 0.443 0.369]
        imgs = [
            (camera),
            (Augmentor.prepareaffine(camera)),
            (OffsetArray(camera, -10, -30)),
            (view(camera, IdentityRange(1:512), IdentityRange(1:512))),
        ]
        @testset "single image" begin
            for img_in in imgs
                res = @inferred(Augmentor.applyeager(Resize(5,5), img_in))
                @test res == ref
                @test typeof(res) == typeof(ref)
            end
        end
        @testset "multiple images" begin
            for img_in1 in imgs
                img_in2 = N0f8.(img_in1)
                img_out1 = ref
                img_out2 = N0f8.(ref)
                img_in = (img_in1, img_in2)
                img_out = (img_out1, img_out2)
                res = @inferred(Augmentor.applyeager(Resize(5,5), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
            end
        end
    end
    @testset "affine" begin
        @test Augmentor.supports_affine(Resize) === false
    end
    @testset "affineview" begin
        @test Augmentor.supports_affineview(Resize) === true
        @test_throws MethodError Augmentor.applyaffineview(Resize(10,10), nothing)
        @test @inferred(Augmentor.toaffinemap(Resize(4,9), rect)) ≈ AffineMap([2. 0.; 0. 3], [-0.5,-1.0])
        for h in (1,2,3,4,5,9), w in (1,2,3,4,5,9)
            wv = @inferred Augmentor.applyaffineview(Resize(h,w), Augmentor.prepareaffine(square))
            @test eltype(wv) == eltype(square)
            @test typeof(wv) <: SubArray
            @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
            @test typeof(parent(wv)) <: InvWarpedView
            @test parent(parent(wv)).itp.coefs === square
            # round because `imresize` computes as float space,
            # while applyaffineview doesn't
            @test round.(Float64.(wv),1) == round.(Float64.(imresize(square, h, w)),1)
        end
        for h in (1,2,3,4,5,9), w in (1,2,3,4,5,9) # bigger show drift
            wv = @inferred Augmentor.applyaffineview(Resize(h,w), Augmentor.prepareaffine(checkers))
            @test eltype(wv) == eltype(checkers)
            @test typeof(wv) <: SubArray
            @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
            @test typeof(parent(wv)) <: InvWarpedView
            @test parent(parent(wv)).itp.coefs === checkers
            @test wv == imresize(checkers, h, w)
        end
        for h in (3,10,29,30,64), w in (3,10,29,30,64)
            (h, w) == (30, 3) && continue # weird tiny artifact in one pixel at []
            wv = @inferred Augmentor.applyaffineview(Resize(h,w), Augmentor.prepareaffine(camera))
            @test eltype(wv) == eltype(camera)
            @test typeof(wv) <: SubArray
            @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
            @test typeof(parent(wv)) <: InvWarpedView
            @test parent(parent(wv)).itp.coefs === camera
            @test wv == imresize(camera, h, w)
        end
    end
    @testset "lazy" begin
        @test Augmentor.supports_lazy(Resize) === true
        @testset "single image" begin
            wv = @inferred Augmentor.applylazy(Resize(2,3), square)
            @test eltype(wv) == eltype(square)
            @test typeof(wv) <: SubArray
            @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
            @test typeof(parent(wv)) <: InvWarpedView
            @test typeof(parent(parent(wv))) <: Interpolations.Extrapolation
            @test parent(parent(wv)).itp.coefs === square
            @test wv == imresize(square, 2, 3)
        end
        @testset "multiple images" begin
            wv1, wv2 = @inferred Augmentor.applylazy(Resize(2,3), (square, square2))
            @test typeof(wv1) <: SubArray
            @test typeof(wv1.indexes) <: Tuple{Vararg{IdentityRange}}
            @test typeof(parent(wv1)) <: InvWarpedView
            @test typeof(parent(parent(wv1))) <: Interpolations.Extrapolation
            @test parent(parent(wv1)).itp.coefs === square
            @test wv1 == imresize(square, 2, 3)
            @test typeof(wv2) <: SubArray
            @test typeof(wv2.indexes) <: Tuple{Vararg{IdentityRange}}
            @test typeof(parent(wv2)) <: InvWarpedView
            @test typeof(parent(parent(wv2))) <: Interpolations.Extrapolation
            @test parent(parent(wv2)).itp.coefs === square2
            @test wv2 == imresize(square2, 2, 3)
        end
    end
    @testset "view" begin
        @test Augmentor.supports_view(Resize) === false
    end
    @testset "stepview" begin
        @test Augmentor.supports_stepview(Resize) === false
    end
    @testset "permute" begin
        @test Augmentor.supports_permute(Resize) === false
    end
end
