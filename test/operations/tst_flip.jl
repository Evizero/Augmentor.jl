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
        @test @inferred(Augmentor.supports_eager(FlipX)) === true
        for img in (rect, OffsetArray(rect, -2, -1), view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applyeager(FlipX(), img)) == flipdim(rect,2)
            @test typeof(Augmentor.applyeager(FlipX(), img)) <: Array
        end
    end
    @testset "affine" begin
        @test @inferred(Augmentor.isaffine(FlipX)) === true
        @test @inferred(Augmentor.supports_affine(FlipX)) === true
        @test_throws MethodError Augmentor.applyaffine(FlipX(), nothing)
        @test @inferred(Augmentor.toaffine(FlipX(), rect)) ≈ AffineMap([1. 0.; 0. -1.], [0.0,4.0])
        wv = @inferred Augmentor.applyaffine(FlipX(), Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test wv == flipdim(square,2)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "lazy" begin
        @test @inferred(Augmentor.supports_lazy(FlipX)) === true
        v = @inferred Augmentor.applylazy(FlipX(), rect)
        @test v === view(rect, 1:1:2, 3:-1:1)
        @test v == flipdim(rect,2)
        @test typeof(v) <: SubArray
        wv = @inferred Augmentor.applylazy(FlipX(), Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test wv == flipdim(square,2)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "view" begin
        @test @inferred(Augmentor.supports_view(FlipX)) === false
    end
    @testset "stepview" begin
        @test @inferred(Augmentor.supports_stepview(FlipX)) === true
        v = @inferred Augmentor.applylazy(FlipX(), rect)
        @test v === view(rect, 1:1:2, 3:-1:1)
        @test v == flipdim(rect,2)
        @test typeof(v) <: SubArray
    end
    @testset "permute" begin
        @test @inferred(Augmentor.supports_permute(FlipX)) === false
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
        @test @inferred(Augmentor.supports_eager(FlipY)) === true
        for img in (rect, OffsetArray(rect, -2, -1), view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applyeager(FlipY(), img)) == flipdim(rect,1)
            @test typeof(Augmentor.applyeager(FlipY(), img)) <: Array
        end
    end
    @testset "affine" begin
        @test @inferred(Augmentor.isaffine(FlipY)) === true
        @test @inferred(Augmentor.supports_affine(FlipY)) === true
        @test_throws MethodError Augmentor.applyaffine(FlipY(), nothing)
        @test @inferred(Augmentor.toaffine(FlipY(), rect)) ≈ AffineMap([-1. 0.; 0. 1.], [3.0,0.0])
        wv = @inferred Augmentor.applyaffine(FlipY(), Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test wv == flipdim(square,1)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "lazy" begin
        @test @inferred(Augmentor.supports_lazy(FlipY)) === true
        v = @inferred Augmentor.applylazy(FlipY(), rect)
        @test v === view(rect, 2:-1:1, 1:1:3)
        @test v == flipdim(rect,1)
        @test typeof(v) <: SubArray
        wv = @inferred Augmentor.applylazy(FlipY(), Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test wv == flipdim(square,1)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "view" begin
        @test @inferred(Augmentor.supports_view(FlipY)) === false
    end
    @testset "stepview" begin
        @test @inferred(Augmentor.supports_stepview(FlipY)) === true
        v = @inferred Augmentor.applylazy(FlipY(), rect)
        @test v === view(rect, 2:-1:1, 1:1:3)
        @test v == flipdim(rect,1)
        @test typeof(v) <: SubArray
    end
    @testset "permute" begin
        @test @inferred(Augmentor.supports_permute(FlipY)) === false
    end
end
