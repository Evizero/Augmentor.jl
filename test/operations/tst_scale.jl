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
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(Scale(10), nothing)
        @test Augmentor.supports_eager(Scale) === false
        for img in (square, OffsetArray(square, 0, 0), view(square, IdentityRange(1:3), IdentityRange(1:3)))
            wv = @inferred(Augmentor.applyeager(Scale(2), img))
            @test size(wv) == (5,5)
            @test typeof(wv) <: Array
            wv = @inferred(Augmentor.applyeager(Scale(2,3), img))
            @test size(wv) == (5,7)
            @test typeof(wv) <: Array
        end
    end
    @testset "affine" begin
        @test Augmentor.isaffine(Scale) === true
        @test Augmentor.supports_affine(Scale) === true
        @test_throws MethodError Augmentor.applyaffine(Scale(90), nothing)
        @test @inferred(Augmentor.toaffine(Scale(2,3), rect)) ≈ AffineMap([2. 0.; 0. 3.], [-1.5,-4.0])
        @test @inferred(Augmentor.toaffine(Scale([0.9,0.9],[0.8,0.8]), rect)) ≈ AffineMap([.9 0.; 0. .8], [0.15,0.4])
        wv = @inferred Augmentor.applyaffine(Scale(2,3), Augmentor.prepareaffine(square))
        # TODO: better tests
        @test parent(wv).itp.coefs === square
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "lazy" begin
        @test Augmentor.supports_lazy(Scale) === true
        wv = @inferred Augmentor.applylazy(Scale(2,3), square)
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
