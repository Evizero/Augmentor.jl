@test typeof(@inferred(NoOp())) <: NoOp <: Augmentor.AffineOperation

@testset "constructor" begin
    @test str_show(NoOp()) == "Augmentor.NoOp()"
    @test str_showconst(NoOp()) == "NoOp()"
    @test str_showcompact(NoOp()) == "No operation"
end
@testset "eager" begin
    @test_throws MethodError Augmentor.applyeager(NoOp(), nothing)
    @test Augmentor.supports_eager(NoOp) === false
    res1 = rect
    res2 = OffsetArray(rect, -2, -1)
    res3 = OffsetArray(rect, 0, 0)
    imgs = [
        (rect, res1),
        (view(rect, :, :), res1),
        (Augmentor.prepareaffine(rect), res3),
        (OffsetArray(rect, -2, -1), res2),
        (view(rect, IdentityRange(1:2), IdentityRange(1:3)), res3),
    ]
    @testset "single image" begin
        for (img_in, img_out) in imgs
            res = @inferred(Augmentor.applyeager(NoOp(), img_in))
            @test res == img_out
            @test typeof(res) == typeof(img_out)
        end
    end
end
@testset "affine" begin
    @test_throws MethodError Augmentor.toaffinemap(NoOp(), nothing)
    @test Augmentor.supports_affine(NoOp) === true
    @test @inferred(Augmentor.toaffinemap(NoOp(), rect)) == AffineMap(@SMatrix([1. 0; 0 1]), @SVector([0., 0.]))
    wv = @inferred Augmentor.applyaffine(NoOp(), rect)
    @test wv == rect
    @test typeof(wv) <: InvWarpedView{eltype(rect),2}
end
@testset "affineview" begin
    @test Augmentor.supports_affineview(NoOp) === true
    wv = @inferred Augmentor.applyaffineview(NoOp(), rect)
    @test typeof(wv) <: SubArray{eltype(rect),2}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)) === rect
    @test wv == rect
end
@testset "lazy" begin
    @test Augmentor.supports_lazy(NoOp) === true
    @test @inferred(Augmentor.applylazy(NoOp(), rect)) === rect
    oa = OffsetArray(rect, -2, -1)
    @test @inferred(Augmentor.applylazy(NoOp(), oa)) === oa
    wv = Augmentor.prepareaffine(rect)
    @test @inferred(Augmentor.applylazy(NoOp(), wv)) === wv
    res1 = rect
    res2 = OffsetArray(rect, -2, -1)
    res3 = OffsetArray(rect, 0, 0)
    imgs = [
        (rect, res1),
        (view(rect, :, :), res1),
        (Augmentor.prepareaffine(rect), res3),
        (OffsetArray(rect, -2, -1), res2),
        (view(rect, IdentityRange(1:2), IdentityRange(1:3)), res3),
    ]
    @testset "single image" begin
        for (img_in, img_out) in imgs
            res = @inferred(Augmentor.applylazy(NoOp(), img_in))
            @test res == img_out
        end
    end
end
@testset "view" begin
    @test Augmentor.supports_view(NoOp) === true
    @test @inferred(Augmentor.applyview(NoOp(), rect)) === view(rect, IdentityRange(1:2), IdentityRange(1:3))
end
@testset "stepview" begin
    @test Augmentor.supports_stepview(NoOp) === true
    @test @inferred(Augmentor.applystepview(NoOp(), rect)) === view(rect, 1:1:2, 1:1:3)
end
@testset "permute" begin
    @test Augmentor.supports_permute(NoOp) === false
end
