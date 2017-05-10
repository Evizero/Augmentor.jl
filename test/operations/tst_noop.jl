@test typeof(@inferred(NoOp())) <: NoOp <: Augmentor.AffineOperation

@testset "constructor" begin
    @test str_show(NoOp()) == "Augmentor.NoOp()"
    @test str_showcompact(NoOp()) == "No operation"
end
@testset "eager" begin
    @test_throws MethodError Augmentor.applyeager(NoOp(), nothing)
    @test @inferred(Augmentor.supports_eager(NoOp)) === false
    @test @inferred(Augmentor.applyeager(NoOp(), rect)) === rect
    @test @inferred(Augmentor.applyeager(NoOp(), OffsetArray(rect, (-1,-2)))) === rect
end
@testset "affine" begin
    @test_throws MethodError Augmentor.toaffine(NoOp(), nothing)
    @test @inferred(Augmentor.isaffine(NoOp)) === true
    @test @inferred(Augmentor.supports_affine(NoOp)) === true
    @test @inferred(Augmentor.toaffine(NoOp(), rect)) == AffineMap(@SMatrix([1. 0; 0 1]), @SVector([0., 0.]))
    wv = @inferred Augmentor.applyaffine(NoOp(), rect)
    @test wv == rect
    @test typeof(wv) <: InvWarpedView{eltype(rect),2}
end
@testset "lazy" begin
    @test @inferred(Augmentor.supports_lazy(NoOp)) === true
    @test @inferred(Augmentor.applylazy(NoOp(), nothing)) === nothing
    @test @inferred(Augmentor.applylazy(NoOp(), rect)) === rect
    wv = Augmentor.prepareaffine(rect)
    @test @inferred(Augmentor.applylazy(NoOp(), wv)) === wv
end
@testset "view" begin
    @test @inferred(Augmentor.supports_view(NoOp)) === true
    @test @inferred(Augmentor.applyview(NoOp(), rect)) === view(rect, IdentityRange(1:2), IdentityRange(1:3))
end
@testset "stepview" begin
    @test @inferred(Augmentor.supports_stepview(NoOp)) === true
    @test @inferred(Augmentor.applystepview(NoOp(), rect)) === view(rect, 1:1:2, 1:1:3)
end
@testset "permute" begin
    @test @inferred(Augmentor.supports_permute(NoOp)) === false
end
