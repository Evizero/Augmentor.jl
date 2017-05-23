@testset "Zoom" begin
    @test (Zoom <: Augmentor.AffineOperation) == false
    @test typeof(@inferred(Zoom(1))) <: Zoom <: Augmentor.Operation
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
        @test str_show(op) == "Augmentor.Zoom{2}(([1.0,$(SPACE)2.0],$(SPACE)[2.0,$(SPACE)3.0]))"
        @test str_showconst(op) == "Zoom([1.0,$(SPACE)2.0], [2.0,$(SPACE)3.0])"
        @test str_showcompact(op) == "Zoom by I ∈ {1.0×2.0, 2.0×3.0}"
        op = @inferred(Zoom([1,2],[2.,3]))
        @test op.factors == ([1.,2.],[2.,3.])
        op = @inferred(Zoom([1,2]))
        @test op.factors == ([1.,2.],[1.,2.])
        op = @inferred(Zoom(1))
        @test str_show(op) == "Augmentor.Zoom{2}((1,$(SPACE)1))"
        @test str_showconst(op) == "Zoom(1, 1)"
        @test str_showcompact(op) == "Zoom by 1×1"
        op = @inferred(Zoom(0.8,0.9))
        @test str_show(op) == "Augmentor.Zoom{2}((0.8,$(SPACE)0.9))"
        @test str_showconst(op) == "Zoom(0.8, 0.9)"
        @test str_showcompact(op) == "Zoom by 0.8×0.9"
        op = @inferred(Zoom(1:2,3:4))
        @test str_show(op) == "Augmentor.Zoom{2}((1:2,$(SPACE)3:4))"
        @test str_showconst(op) == "Zoom(1:2, 3:4)"
        @test str_showcompact(op) == "Zoom by I ∈ {1×3, 2×4}"
        op = @inferred(Zoom(1:3,3:5))
        @test str_show(op) == "Augmentor.Zoom{2}((1:3,$(SPACE)3:5))"
        @test str_showconst(op) == "Zoom(1:3, 3:5)"
        @test str_showcompact(op) == "Zoom by I ∈ {1×3, 2×4, 3×5}"
        op = @inferred(Zoom(1,2,3))
        @test str_show(op) == "Augmentor.Zoom{3}((1,$(SPACE)2,$(SPACE)3))"
        @test str_showconst(op) == "Zoom(1, 2, 3)"
        @test str_showcompact(op) == "Zoom by 1×2×3"
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(Zoom(10), nothing)
        @test @inferred(Augmentor.supports_eager(Zoom)) === false
        for img in (square, OffsetArray(square, 0, 0), view(square, IdentityRange(1:3), IdentityRange(1:3)))
            wv = @inferred(Augmentor.applyeager(Zoom(2), img))
            @test size(wv) == (3,3)
            @test typeof(wv) <: Array
            wv = @inferred(Augmentor.applyeager(Zoom(2,3), img))
            @test size(wv) == (3,3)
            @test typeof(wv) <: Array
        end
    end
    @testset "affine" begin
        @test @inferred(Augmentor.isaffine(Zoom)) === false
        @test @inferred(Augmentor.supports_affine(Zoom)) === true
        @test_throws MethodError Augmentor.applyaffine(Zoom(90), nothing)
        @test @inferred(Augmentor.toaffine(Zoom(2,3), rect)) ≈ AffineMap([2. 0.; 0. 3.], [-1.5,-4.0])
        @test @inferred(Augmentor.toaffine(Zoom([0.9,0.9],[0.8,0.8]), rect)) ≈ AffineMap([.9 0.; 0. .8], [0.15,0.4])
        wv = @inferred Augmentor.applyaffine(Zoom(2,3), Augmentor.prepareaffine(square))
        # TODO: better tests
        @test eltype(wv) == eltype(square)
        @test typeof(wv) <: SubArray
        @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
        @test typeof(parent(wv)) <: InvWarpedView
        @test parent(parent(wv)).itp.coefs === square
    end
    @testset "lazy" begin
        @test @inferred(Augmentor.supports_lazy(Zoom)) === true
        wv = @inferred Augmentor.applylazy(Zoom(2,3), square)
        # TODO: better tests
        @test eltype(wv) == eltype(square)
        @test typeof(wv) <: SubArray
        @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
        @test typeof(parent(wv)) <: InvWarpedView
        @test parent(parent(wv)).itp.coefs === square
    end
    @testset "view" begin
        @test @inferred(Augmentor.supports_view(Zoom)) === false
    end
    @testset "stepview" begin
        @test @inferred(Augmentor.supports_stepview(Zoom)) === false
    end
    @testset "permute" begin
        @test @inferred(Augmentor.supports_permute(Zoom)) === false
    end
end
