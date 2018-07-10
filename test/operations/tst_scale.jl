@testset "Scale" begin
    @test typeof(@inferred(Scale(1))) <: Scale <: Augmentor.AffineOperation
    @testset "constructor" begin
        @test_throws MethodError Scale()
        @test_throws MethodError Scale(())
        @test_throws MethodError Scale{0}(())
        @test_throws MethodError Scale(:a)
        @test_throws MethodError Scale([:a])
        @test_throws ArgumentError Scale([])
        @test_throws ArgumentError Scale{1}(([:a],))
        @test_throws ArgumentError Scale(1:3,1:2)
        @test_throws ArgumentError Scale(1:2,1:2,1)
        @test @inferred(Scale(1,2)) == @inferred(Scale{2}((1,2)))
        @test @inferred(Scale(1)) == @inferred(Scale{2}((1:1,1:1)))
        @test @inferred(Scale((1,))) == Scale{1}((1:1,))
        @test @inferred(Scale(1,2)) == Scale{2}((1:1,2:2))
        @test @inferred(Scale(1.)) == Scale{2}((1.0:1:1,1.0:1:1))
        @test @inferred(Scale(1,2,3.)) == Scale{3}((1.0:1,2.0:2,3.0:3))
        @test @inferred(Scale(1,2,3)) == Scale{3}((1:1,2:2,3:3))
        @test @inferred(Scale(1:1,2,3)) == Scale{3}((1:1,2:2,3:3))
        @test @inferred(Scale((1,2,3))) == Scale{3}((1:1,2:2,3:3))
        @test @inferred(Scale(1:2,2:3)) == Scale{2}((1:2,2:3))
        @test @inferred(Scale((1:2,2:3))) == Scale{2}((1:2,2:3))
        op = @inferred(Scale([1,2],2:3))
        @test op.factors == ([1.,2.],[2.,3.])
        @test str_show(op) == "Augmentor.Scale{2}(([1.0, 2.0], [2.0, 3.0]))"
        @test str_showconst(op) == "Scale([1.0, 2.0], [2.0, 3.0])"
        @test str_showcompact(op) == "Scale by I ∈ {1.0×2.0, 2.0×3.0}"
        op = @inferred(Scale([1,2],[2.,3]))
        @test op.factors == ([1.,2.],[2.,3.])
        op = @inferred(Scale([1,2]))
        @test op.factors == ([1.,2.],[1.,2.])
        op = @inferred(Scale(1))
        @test str_show(op) == "Augmentor.Scale{2}((1, 1))"
        @test str_showconst(op) == "Scale(1, 1)"
        @test str_showcompact(op) == "Scale by 1×1"
        op = @inferred(Scale(0.8,0.9))
        @test str_show(op) == "Augmentor.Scale{2}((0.8, 0.9))"
        @test str_showconst(op) == "Scale(0.8, 0.9)"
        @test str_showcompact(op) == "Scale by 0.8×0.9"
        op = @inferred(Scale(1:2,3:4))
        @test str_show(op) == "Augmentor.Scale{2}((1:2, 3:4))"
        @test str_showconst(op) == "Scale(1:2, 3:4)"
        @test str_showcompact(op) == "Scale by I ∈ {1×3, 2×4}"
        op = @inferred(Scale(1:3,3:5))
        @test str_show(op) == "Augmentor.Scale{2}((1:3, 3:5))"
        @test str_showconst(op) == "Scale(1:3, 3:5)"
        @test str_showcompact(op) == "Scale by I ∈ {1×3, 2×4, 3×5}"
        op = @inferred(Scale(1,2,3))
        @test str_show(op) == "Augmentor.Scale{3}((1, 2, 3))"
        @test str_showconst(op) == "Scale(1, 2, 3)"
        @test str_showcompact(op) == "Scale by 1×2×3"
    end
    @testset "randparam" begin
        @test @inferred(Augmentor.randparam(Scale(45), rect)) === (45.0, 45.0)
        @test @inferred(Augmentor.randparam(Scale(20.0, 15.0), rect)) === (20.0, 15.0)
        @test @inferred(Augmentor.randparam(Scale(20.0, 15.0), (rect, square2))) === (20.0, 15.0)
        @test @inferred(Augmentor.randparam(Scale(1:2,2:3), rect)) in [(1,2), (2,3)]
        @test @inferred(Augmentor.toaffinemap(Scale(2,3), rect, (2.,3.))) ≈ AffineMap([2. 0.; 0. 3.], [-1.5,-4.0])
        @test @inferred(Augmentor.toaffinemap(Scale([0.9,0.4],[0.8,0.3]), rect, (0.9,0.8))) ≈ AffineMap([.9 0.; 0. .8], [0.15,0.4])
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(Scale(10), nothing)
        @test Augmentor.supports_eager(Scale) === false
        # TODO: actual content tests (maybe test_reference)
        img_out1 = @inferred Augmentor.applyeager(Scale(1.5), square2)
        img_out2 = @inferred Augmentor.applyeager(Scale(0.2), square2)
        @test indices(img_out1) == (0:5, 0:5)
        @test indices(img_out2) == (2:3, 2:3)
        imgs = [
            (square2),
            (view(square2, :, :)),
            (Augmentor.prepareaffine(square2)),
            (OffsetArray(square2, -1, -1)),
            (view(square2, IdentityRange(1:4), IdentityRange(1:4))),
        ]
        @testset "fixed parameter" begin
            for img_in in imgs
                res = @inferred(Augmentor.applyeager(Scale(1.5), img_in))
                @test parent(res) ≈ parent(img_out1)
                @test typeof(res) == typeof(img_out1)
                res = @inferred(Augmentor.applyeager(Scale(0.2), img_in))
                @test parent(res) == parent(img_out2)
                @test typeof(res) == typeof(img_out2)
                # test same with tuple of images
                res1, res2 = @inferred(Augmentor.applyeager(Scale(1.5), (img_in, N0f8.(img_in))))
                @test parent(res1) ≈ parent(img_out1)
                @test parent(res2) == parent(img_out1)
                @test typeof(res1) == typeof(img_out1)
                @test typeof(res2) <: OffsetArray{N0f8}
                res1, res2 = @inferred(Augmentor.applyeager(Scale(0.2), (img_in, N0f8.(img_in))))
                @test parent(res1) ≈ parent(img_out2)
                @test parent(res2) == parent(img_out2)
                @test typeof(res1) == typeof(img_out2)
                @test typeof(res2) <: OffsetArray{N0f8}
            end
            # check that the affine map is computed for each image
            res1, res2 = @inferred(Augmentor.applyeager(Scale(1.5), (square, OffsetArray(square,-5,-5))))
            @test collect(res1) == collect(res2)
            @test indices(res1) != indices(res2)
        end
        @testset "random parameter" begin
            for img_in in imgs
                res1, res2 = @inferred(Augmentor.applyeager(Scale(.5:.1:2., .6:.1:2.1), (img_in, N0f8.(img_in))))
                # make sure same scales are used
                @test res1 == res2
                @test typeof(res1) == typeof(img_out1)
                @test typeof(res2) <: OffsetArray{N0f8}
            end
        end
    end
    ref = @inferred Augmentor.applyeager(Scale(2,3), square)
    @testset "affine" begin
        @test Augmentor.supports_affine(Scale) === true
        @test_throws MethodError Augmentor.applyaffine(Scale(90), nothing)
        wv = @inferred Augmentor.applyaffine(Scale(2,3), Augmentor.prepareaffine(square))
        @test wv == ref
        # TODO: better tests
        @test parent(wv).itp.coefs === square
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "affineview" begin
        @test Augmentor.supports_affineview(Scale) === true
        @test_throws MethodError Augmentor.applyaffineview(Scale(90), nothing)
        wv = @inferred Augmentor.applyaffineview(Scale(2,3), Augmentor.prepareaffine(square))
        @test wv == ref
        # TODO: better tests
        @test typeof(wv) <: SubArray{eltype(square),2}
        @test typeof(parent(wv)) <: InvWarpedView
        @test parent(parent(wv)).itp.coefs === square
    end
    @testset "lazy" begin
        @test Augmentor.supports_lazy(Scale) === true
        wv = @inferred Augmentor.applylazy(Scale(2,3), square)
        @test wv == ref
        # TODO: better tests
        @test parent(wv).itp.coefs === square
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "view" begin
        @test Augmentor.supports_view(Scale) === false
    end
    @testset "stepview" begin
        @test Augmentor.supports_stepview(Scale) === false
    end
    @testset "permute" begin
        @test Augmentor.supports_permute(Scale) === false
    end
end
