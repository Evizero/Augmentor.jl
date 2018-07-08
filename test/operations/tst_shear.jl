@testset "ShearX" begin
    @test typeof(@inferred(ShearX(1))) <: ShearX <: Augmentor.AffineOperation
    @testset "constructor" begin
        @test_throws MethodError ShearX()
        @test_throws MethodError ShearX(:a)
        @test_throws MethodError ShearX([:a])
        @test_throws ArgumentError ShearX(3:1)
        @test_throws ArgumentError ShearX(-71:1)
        @test_throws ArgumentError ShearX(1:71)
        @test_throws ArgumentError ShearX([2,71,-4])
        @test_throws ArgumentError ShearX(71)
        @test @inferred(ShearX(70)) === ShearX(70:70)
        @test @inferred(ShearX(-70)) === ShearX(-70:-70)
        @test @inferred(ShearX(0.7)) === ShearX(0.7:1:0.7)
        @test str_show(ShearX(0.7)) == "Augmentor.ShearX(0.7)"
        @test str_showconst(ShearX(0.7)) == "ShearX(0.7)"
        @test str_showcompact(ShearX(0.7)) == "ShearX 0.7 degree"
        @test @inferred(ShearX(10)) === ShearX(10:10)
        @test str_show(ShearX(10)) == "Augmentor.ShearX(10)"
        @test str_showconst(ShearX(10)) == "ShearX(10)"
        @test str_showcompact(ShearX(10)) == "ShearX 10 degree"
        op = @inferred(ShearX(-1:1))
        @test str_show(op) == "Augmentor.ShearX(-1:1)"
        @test str_showconst(op) == "ShearX(-1:1)"
        @test str_showcompact(op) == "ShearX by ϕ ∈ -1:1 degree"
        op = @inferred(ShearX([2,30]))
        @test op.degree == [2,30]
        @test str_show(op) == "Augmentor.ShearX([2, 30])"
        @test str_showconst(op) == "ShearX([2, 30])"
        @test str_showcompact(op) == "ShearX by ϕ ∈ [2, 30] degree"
    end
    @testset "randparam" begin
        @test @inferred(Augmentor.randparam(ShearX(45), rect)) === 45.0
        @test @inferred(Augmentor.randparam(ShearX(20.0), rect)) === 20.0
        @test @inferred(Augmentor.randparam(ShearX(1:10), rect)) in 1:10
        @test_throws MethodError Augmentor.toaffinemap(ShearX(45), rect)
        @test @inferred(Augmentor.toaffinemap(ShearX(45), rect, 45)) ≈ AffineMap([1. 0.; -1. 1.], [0.,1.5])
        @test @inferred(Augmentor.toaffinemap(ShearX(-60:60), rect, 45)) ≈ AffineMap([1. 0.; -1. 1.], [0.,1.5])
        @test @inferred(Augmentor.toaffinemap(ShearX(-45), rect, -45)) ≈ AffineMap([1. 0.; 1. 1.], [0.,-1.5])
        @test @inferred(Augmentor.toaffinemap(ShearX(-60:1:60), rect, -45)) ≈ AffineMap([1. 0.; 1. 1.], [0.,-1.5])
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(ShearX(10), nothing)
        @test Augmentor.supports_eager(ShearX) === false
        # TODO: actual content tests (maybe test_reference)
        img_out1 = @inferred Augmentor.applyeager(ShearX(45), square)
        img_out2 = @inferred Augmentor.applyeager(ShearX(-45), square)
        @test indices(img_out1) == (1:3, 0:4)
        @test indices(img_out1) == indices(img_out2)
        imgs = [
            (square),
            (view(square, :, :)),
            (Augmentor.prepareaffine(square)),
            (OffsetArray(square, -1, -1)),
            (view(square, IdentityRange(1:3), IdentityRange(1:3))),
        ]
        @testset "fixed parameter" begin
            for img_in in imgs
                res = @inferred(Augmentor.applyeager(ShearX(45), img_in))
                @test parent(res) == parent(img_out1)
                @test typeof(res) == typeof(img_out1)
                res = @inferred(Augmentor.applyeager(ShearX(-45), img_in))
                @test parent(res) == parent(img_out2)
                @test typeof(res) == typeof(img_out2)
                # test same with tuple of images
                res1, res2 = @inferred(Augmentor.applyeager(ShearX(45), (img_in, N0f8.(img_in))))
                @test parent(res1) == parent(img_out1)
                @test parent(res2) == parent(img_out1)
                @test typeof(res1) == typeof(img_out1)
                @test typeof(res2) <: OffsetArray{N0f8}
                res1, res2 = @inferred(Augmentor.applyeager(ShearX(-45), (img_in, N0f8.(img_in))))
                @test parent(res1) == parent(img_out2)
                @test parent(res2) == parent(img_out2)
                @test typeof(res1) == typeof(img_out2)
                @test typeof(res2) <: OffsetArray{N0f8}
            end
            # check that the affine map is computed for each image
            res1, res2 = @inferred(Augmentor.applyeager(ShearX(45), (square, OffsetArray(square,-5,-5))))
            @test collect(res1) == collect(res2)
            @test indices(res1) != indices(res2)
        end
        @testset "random parameter" begin
            for img_in in imgs
                res1, res2 = @inferred(Augmentor.applyeager(ShearX(1:60), (img_in, N0f8.(img_in))))
                # make sure same angle is used
                @test res1 == res2
                @test typeof(res1) == typeof(img_out1)
                @test typeof(res2) <: OffsetArray{N0f8}
            end
        end
    end
    @testset "affine" begin
        @test Augmentor.supports_affine(ShearX) === true
        @test_throws MethodError Augmentor.applyaffine(ShearX(45), nothing)
        wv = @inferred Augmentor.applyaffine(ShearX(45), Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test indices(wv) == (1:3,0:4)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
        wv2 = @inferred Augmentor.applyaffine(ShearX(-45), wv)
        @test parent(wv).itp.coefs === square
        @test wv2[1:3,1:3] == square
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "affineview" begin
        @test Augmentor.supports_affineview(ShearX) === true
        @test_throws MethodError Augmentor.applyaffineview(ShearX(45), nothing)
        wv = @inferred Augmentor.applyaffineview(ShearX(45), Augmentor.prepareaffine(square))
        @test typeof(wv) <: SubArray{eltype(square),2}
        @test typeof(parent(wv)) <: InvWarpedView
        @test parent(parent(wv)).itp.coefs === square
        @test indices(wv) == (1:3,0:4)
        wv2 = @inferred Augmentor.applyaffineview(ShearX(-45), wv)
        @test wv2[1:3,1:3] == square
        @test typeof(wv2) <: SubArray{eltype(square),2}
        @test typeof(parent(wv2)) <: InvWarpedView
        @test parent(parent(wv2)).itp.coefs === square
    end
    @testset "lazy" begin
        @test Augmentor.supports_lazy(ShearX(45)) === true
        wv = @inferred Augmentor.applylazy(ShearX(45), square)
        @test parent(wv).itp.coefs === square
        @test indices(wv) == (1:3,0:4)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
        wv2 = @inferred Augmentor.applylazy(ShearX(-45), wv)
        @test parent(wv).itp.coefs === square
        @test wv2[1:3,1:3] == square
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "view" begin
        @test Augmentor.supports_view(ShearX) === false
    end
    @testset "stepview" begin
        @test Augmentor.supports_stepview(ShearX) === false
    end
    @testset "permute" begin
        @test Augmentor.supports_permute(ShearX) === false
    end
end

# --------------------------------------------------------------------

@testset "ShearY" begin
    @test typeof(@inferred(ShearY(1))) <: ShearY <: Augmentor.AffineOperation
    @testset "constructor" begin
        @test_throws MethodError ShearY()
        @test_throws MethodError ShearY(:a)
        @test_throws MethodError ShearY([:a])
        @test_throws ArgumentError ShearY(3:1)
        @test_throws ArgumentError ShearY(-71:1)
        @test_throws ArgumentError ShearY(1:71)
        @test_throws ArgumentError ShearY([2,71,-4])
        @test_throws ArgumentError ShearY(71)
        @test @inferred(ShearY(70)) === ShearY(70:70)
        @test @inferred(ShearY(-70)) === ShearY(-70:-70)
        @test @inferred(ShearY(0.7)) === ShearY(0.7:1:0.7)
        @test str_show(ShearY(0.7)) == "Augmentor.ShearY(0.7)"
        @test str_showconst(ShearY(0.7)) == "ShearY(0.7)"
        @test str_showcompact(ShearY(0.7)) == "ShearY 0.7 degree"
        @test @inferred(ShearY(10)) === ShearY(10:10)
        @test str_show(ShearY(10)) == "Augmentor.ShearY(10)"
        @test str_showconst(ShearY(10)) == "ShearY(10)"
        @test str_showcompact(ShearY(10)) == "ShearY 10 degree"
        op = @inferred(ShearY(-1:1))
        @test str_show(op) == "Augmentor.ShearY(-1:1)"
        @test str_showconst(op) == "ShearY(-1:1)"
        @test str_showcompact(op) == "ShearY by ψ ∈ -1:1 degree"
        op = @inferred(ShearY([2,30]))
        @test op.degree == [2,30]
        @test str_show(op) == "Augmentor.ShearY([2, 30])"
        @test str_showconst(op) == "ShearY([2, 30])"
        @test str_showcompact(op) == "ShearY by ψ ∈ [2, 30] degree"
    end
    @testset "randparam" begin
        @test @inferred(Augmentor.randparam(ShearY(45), rect)) === 45.0
        @test @inferred(Augmentor.randparam(ShearY(20.0), rect)) === 20.0
        @test @inferred(Augmentor.randparam(ShearY(1:10), rect)) in 1:10
        @test_throws MethodError Augmentor.toaffinemap(ShearY(45), rect)
        @test @inferred(Augmentor.toaffinemap(ShearY(45), rect, 45)) ≈ AffineMap([1. -1.; 0. 1.], [2.,0.])
        @test @inferred(Augmentor.toaffinemap(ShearY(-60:60), rect, 45)) ≈ AffineMap([1. -1.; 0. 1.], [2.,0.])
        @test @inferred(Augmentor.toaffinemap(ShearY(-45), rect, -45)) ≈ AffineMap([1. 1.; 0. 1.], [-2.,0.])
        @test @inferred(Augmentor.toaffinemap(ShearY(-60:1:60), rect, -45)) ≈ AffineMap([1. 1.; 0. 1.], [-2.,0.])
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(ShearY(10), nothing)
        @test Augmentor.supports_eager(ShearY) === false
        # TODO: actual content tests (maybe test_reference)
        img_out1 = @inferred Augmentor.applyeager(ShearY(45), square)
        img_out2 = @inferred Augmentor.applyeager(ShearY(-45), square)
        @test indices(img_out1) == (0:4, 1:3)
        @test indices(img_out1) == indices(img_out2)
        imgs = [
            (square),
            (view(square, :, :)),
            (Augmentor.prepareaffine(square)),
            (OffsetArray(square, -1, -1)),
            (view(square, IdentityRange(1:3), IdentityRange(1:3))),
        ]
        @testset "fixed parameter" begin
            for img_in in imgs
                res = @inferred(Augmentor.applyeager(ShearY(45), img_in))
                @test parent(res) == parent(img_out1)
                @test typeof(res) == typeof(img_out1)
                res = @inferred(Augmentor.applyeager(ShearY(-45), img_in))
                @test parent(res) == parent(img_out2)
                @test typeof(res) == typeof(img_out2)
                # test same with tuple of images
                res1, res2 = @inferred(Augmentor.applyeager(ShearY(45), (img_in, N0f8.(img_in))))
                @test parent(res1) == parent(img_out1)
                @test parent(res2) == parent(img_out1)
                @test typeof(res1) == typeof(img_out1)
                @test typeof(res2) <: OffsetArray{N0f8}
                res1, res2 = @inferred(Augmentor.applyeager(ShearY(-45), (img_in, N0f8.(img_in))))
                @test parent(res1) == parent(img_out2)
                @test parent(res2) == parent(img_out2)
                @test typeof(res1) == typeof(img_out2)
                @test typeof(res2) <: OffsetArray{N0f8}
            end
            # check that the affine map is computed for each image
            res1, res2 = @inferred(Augmentor.applyeager(ShearY(45), (square, OffsetArray(square,-5,-5))))
            @test collect(res1) == collect(res2)
            @test indices(res1) != indices(res2)
        end
        @testset "random parameter" begin
            for img_in in imgs
                res1, res2 = @inferred(Augmentor.applyeager(ShearY(1:60), (img_in, N0f8.(img_in))))
                # make sure same angle is used
                @test res1 == res2
                @test typeof(res1) == typeof(img_out1)
                @test typeof(res2) <: OffsetArray{N0f8}
            end
        end
    end
    @testset "affine" begin
        @test Augmentor.supports_affine(ShearY) === true
        @test_throws MethodError Augmentor.applyaffine(ShearY(45), nothing)
        wv = @inferred Augmentor.applyaffine(ShearY(45), Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test indices(wv) == (0:4,1:3)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
        wv2 = @inferred Augmentor.applyaffine(ShearY(-45), wv)
        @test parent(wv).itp.coefs === square
        @test wv2[1:3,1:3] == square
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "affineview" begin
        @test Augmentor.supports_affineview(ShearY) === true
        @test_throws MethodError Augmentor.applyaffineview(ShearY(45), nothing)
        wv = @inferred Augmentor.applyaffineview(ShearY(45), Augmentor.prepareaffine(square))
        @test typeof(wv) <: SubArray{eltype(square),2}
        @test typeof(parent(wv)) <: InvWarpedView
        @test parent(parent(wv)).itp.coefs === square
        @test indices(wv) == (0:4,1:3)
        wv2 = @inferred Augmentor.applyaffineview(ShearY(-45), wv)
        @test typeof(wv2) <: SubArray{eltype(square),2}
        @test typeof(parent(wv2)) <: InvWarpedView
        @test parent(parent(wv2)).itp.coefs === square
        @test wv2[1:3,1:3] == square
    end
    @testset "lazy" begin
        @test Augmentor.supports_lazy(ShearY(45)) === true
        wv = @inferred Augmentor.applylazy(ShearY(45), square)
        @test parent(wv).itp.coefs === square
        @test indices(wv) == (0:4,1:3)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
        wv2 = @inferred Augmentor.applylazy(ShearY(-45), wv)
        @test parent(wv).itp.coefs === square
        @test wv2[1:3,1:3] == square
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "view" begin
        @test Augmentor.supports_view(ShearY) === false
    end
    @testset "stepview" begin
        @test Augmentor.supports_stepview(ShearY) === false
    end
    @testset "permute" begin
        @test Augmentor.supports_permute(ShearY) === false
    end
end
