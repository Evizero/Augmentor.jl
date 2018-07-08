@testset "Zoom" begin
    @test (Zoom <: Augmentor.AffineOperation) == false
    @test typeof(@inferred(Zoom(1))) <: Zoom <: Augmentor.ImageOperation
    @testset "constructor" begin
        @test_throws MethodError Zoom()
        @test_throws MethodError Zoom(())
        @test_throws MethodError Zoom{0}(())
        @test_throws MethodError Zoom(:a)
        @test_throws MethodError Zoom([:a])
        @test_throws ArgumentError Zoom([])
        @test_throws ArgumentError Zoom{1}(([:a],))
        @test_throws ArgumentError Zoom(1:3,1:2)
        @test_throws ArgumentError Zoom(1:2,1:2,1)
        @test @inferred(Zoom(1,2)) == @inferred(Zoom{2}((1,2)))
        @test @inferred(Zoom(1)) == @inferred(Zoom{2}((1:1,1:1)))
        @test @inferred(Zoom((1,))) == Zoom{1}((1:1,))
        @test @inferred(Zoom(1,2)) == Zoom{2}((1:1,2:2))
        @test @inferred(Zoom(1.)) == Zoom{2}((1.0:1:1,1.0:1:1))
        @test @inferred(Zoom(1,2,3.)) == Zoom{3}((1.0:1,2.0:2,3.0:3))
        @test @inferred(Zoom(1,2,3)) == Zoom{3}((1:1,2:2,3:3))
        @test @inferred(Zoom(1:1,2,3)) == Zoom{3}((1:1,2:2,3:3))
        @test @inferred(Zoom((1,2,3))) == Zoom{3}((1:1,2:2,3:3))
        @test @inferred(Zoom(1:2,2:3)) == Zoom{2}((1:2,2:3))
        @test @inferred(Zoom((1:2,2:3))) == Zoom{2}((1:2,2:3))
        op = @inferred(Zoom([1,2],2:3))
        @test op.factors == ([1.,2.],[2.,3.])
        @test str_show(op) == "Augmentor.Zoom{2}(([1.0, 2.0], [2.0, 3.0]))"
        @test str_showconst(op) == "Zoom([1.0, 2.0], [2.0, 3.0])"
        @test str_showcompact(op) == "Zoom by I ∈ {1.0×2.0, 2.0×3.0}"
        op = @inferred(Zoom([1,2],[2.,3]))
        @test op.factors == ([1.,2.],[2.,3.])
        op = @inferred(Zoom([1,2]))
        @test op.factors == ([1.,2.],[1.,2.])
        op = @inferred(Zoom(1))
        @test str_show(op) == "Augmentor.Zoom{2}((1, 1))"
        @test str_showconst(op) == "Zoom(1, 1)"
        @test str_showcompact(op) == "Zoom by 1×1"
        op = @inferred(Zoom(0.8,0.9))
        @test str_show(op) == "Augmentor.Zoom{2}((0.8, 0.9))"
        @test str_showconst(op) == "Zoom(0.8, 0.9)"
        @test str_showcompact(op) == "Zoom by 0.8×0.9"
        op = @inferred(Zoom(1:2,3:4))
        @test str_show(op) == "Augmentor.Zoom{2}((1:2, 3:4))"
        @test str_showconst(op) == "Zoom(1:2, 3:4)"
        @test str_showcompact(op) == "Zoom by I ∈ {1×3, 2×4}"
        op = @inferred(Zoom(1:3,3:5))
        @test str_show(op) == "Augmentor.Zoom{2}((1:3, 3:5))"
        @test str_showconst(op) == "Zoom(1:3, 3:5)"
        @test str_showcompact(op) == "Zoom by I ∈ {1×3, 2×4, 3×5}"
        op = @inferred(Zoom(1,2,3))
        @test str_show(op) == "Augmentor.Zoom{3}((1, 2, 3))"
        @test str_showconst(op) == "Zoom(1, 2, 3)"
        @test str_showcompact(op) == "Zoom by 1×2×3"
    end
    @testset "randparam" begin
        @test @inferred(Augmentor.randparam(Zoom(45), rect)) === (45.0, 45.0)
        @test @inferred(Augmentor.randparam(Zoom(20.0, 15.0), rect)) === (20.0, 15.0)
        @test @inferred(Augmentor.randparam(Zoom(20.0, 15.0), (rect, square2))) === (20.0, 15.0)
        @test @inferred(Augmentor.randparam(Zoom(1:2,2:3), rect)) in [(1,2), (2,3)]
        @test @inferred(Augmentor.toaffinemap(Zoom(2,3), rect, (2.,3.))) ≈ AffineMap([2. 0.; 0. 3.], [-1.5,-4.0])
        @test @inferred(Augmentor.toaffinemap(Zoom([0.9,0.4],[0.8,0.3]), rect, (0.9,0.8))) ≈ AffineMap([.9 0.; 0. .8], [0.15,0.4])
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(Zoom(10), nothing)
        @test Augmentor.supports_eager(Zoom) === false
        # TODO: actual content tests (maybe test_reference)
        img_out1 = @inferred Augmentor.applyeager(Zoom(1.5), square2)
        img_out2 = @inferred Augmentor.applyeager(Zoom(0.2), square2)
        @test indices(img_out1) == (1:4, 1:4)
        @test indices(img_out2) == (1:4, 1:4)
        imgs = [
            (square2),
            (view(square2, :, :)),
            (Augmentor.prepareaffine(square2)),
            (OffsetArray(square2, -1, -1)),
            (view(square2, IdentityRange(1:4), IdentityRange(1:4))),
        ]
        @testset "fixed parameter" begin
            for img_in in imgs
                res = @inferred(Augmentor.applyeager(Zoom(1.5), img_in))
                @test parent(res) == parent(img_out1)
                @test typeof(res) == typeof(img_out1)
                res = @inferred(Augmentor.applyeager(Zoom(0.2), img_in))
                @test parent(res) == parent(img_out2)
                @test typeof(res) == typeof(img_out2)
                # test same with tuple of images
                res1, res2 = @inferred(Augmentor.applyeager(Zoom(1.5), (img_in, N0f8.(img_in))))
                @test parent(res1) == parent(img_out1)
                @test parent(res2) == parent(img_out1)
                @test typeof(res1) == typeof(img_out1)
                @test typeof(res2) <: OffsetArray{N0f8}
                res1, res2 = @inferred(Augmentor.applyeager(Zoom(0.2), (img_in, N0f8.(img_in))))
                @test parent(res1) == parent(img_out2)
                @test parent(res2) == parent(img_out2)
                @test typeof(res1) == typeof(img_out2)
                @test typeof(res2) <: OffsetArray{N0f8}
            end
            # check that the affine map is computed for each image
            res1, res2 = @inferred(Augmentor.applyeager(Zoom(1.5), (square, OffsetArray(square,-5,-5))))
            @test collect(res1) == collect(res2)
            @test indices(res1) != indices(res2)
            res1, res2 = @inferred(Augmentor.applyeager(Zoom(1.5), (square, square2)))
            @test res1 == Augmentor.applyeager(Zoom(1.5), square)
            @test res2 == Augmentor.applyeager(Zoom(1.5), square2)
        end
        @testset "random parameter" begin
            for img_in in imgs
                res1, res2 = @inferred(Augmentor.applyeager(Zoom(.5:.1:2., .6:.1:2.1), (img_in, N0f8.(img_in))))
                # make sure same scales are used
                @test res1 == res2
                @test typeof(res1) == typeof(img_out1)
                @test typeof(res2) <: OffsetArray{N0f8}
            end
        end
    end
    @testset "affine" begin
        @test Augmentor.supports_affine(Zoom) === false
    end
    ref = @inferred Augmentor.applyeager(Zoom(2,3), square)
    @testset "affineview" begin
        @test Augmentor.supports_affineview(Zoom) === true
        @test_throws MethodError Augmentor.applyaffineview(Zoom(90), nothing)
        wv = @inferred Augmentor.applyaffineview(Zoom(2,3), Augmentor.prepareaffine(square))
        # TODO: better tests
        @test wv == ref
        @test eltype(wv) == eltype(square)
        @test typeof(wv) <: SubArray
        @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
        @test typeof(parent(wv)) <: InvWarpedView
        @test parent(parent(wv)).itp.coefs === square
    end
    @testset "lazy" begin
        @test Augmentor.supports_lazy(Zoom) === true
        wv = @inferred Augmentor.applylazy(Zoom(2,3), square)
        # TODO: better tests
        @test wv == ref
        @test eltype(wv) == eltype(square)
        @test typeof(wv) <: SubArray
        @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
        @test typeof(parent(wv)) <: InvWarpedView
        @test parent(parent(wv)).itp.coefs === square
    end
    @testset "view" begin
        @test Augmentor.supports_view(Zoom) === false
    end
    @testset "stepview" begin
        @test Augmentor.supports_stepview(Zoom) === false
    end
    @testset "permute" begin
        @test Augmentor.supports_permute(Zoom) === false
    end
end
