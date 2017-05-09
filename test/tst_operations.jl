# test not exported
@test_throws UndefVarError Operation
@test_throws UndefVarError AffineOperation

@test Augmentor.AffineOperation <: Augmentor.Operation

@testset "prepare" begin
    @test @inferred(Augmentor.prepareview(rect)) === rect
    @test @inferred(Augmentor.preparestepview(rect)) === rect
    @test @inferred(Augmentor.preparepermute(rect)) === rect
    @test @inferred(Augmentor.preparelazy(rect)) === rect
    wv = @inferred Augmentor.prepareaffine(rect)
    @test typeof(wv) <: InvWarpedView
    @test typeof(parent(wv)) <: Interpolations.Extrapolation
    @test parent(wv).itp.coefs === rect
    @test @inferred(Augmentor.prepareaffine(wv)) === wv
    @test @inferred(Augmentor.prepareaffine(parent(wv))) === wv
    v = view(wv, 1:2, 2:3)
    @test @inferred(Augmentor.prepareaffine(v)) === v
end
