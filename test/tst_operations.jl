# test not exported
@test_throws UndefVarError Operation
@test_throws UndefVarError ImageOperation
@test_throws UndefVarError AffineOperation

@test Augmentor.ImageOperation <: Augmentor.Operation
@test Augmentor.AffineOperation <: Augmentor.ImageOperation

@testset "prepare" begin
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

ops = (Zoom(2.), NoOp()) # make sure Zoom sticks
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor.unroll_applyaffine(ops, rect)
    @test typeof(wv) <: SubArray
    @test indices(wv) == (1:2,1:3)
end

ops = (FlipX(), FlipY())
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor.unroll_applyaffine(ops, rect)
    @test typeof(wv) === typeof(invwarpedview(rect, Augmentor.toaffinemap(NoOp(),rect), Flat()))
    @test wv == rot180(rect)
    wv = @inferred Augmentor.unroll_applylazy(ops, Augmentor.prepareaffine(rect))
    @test typeof(wv) === typeof(invwarpedview(rect, Augmentor.toaffinemap(NoOp(),rect), Flat()))
    @test wv == rot180(rect)
    v = @inferred Augmentor.unroll_applylazy(ops, rect)
    @test v === view(rect, 2:-1:1, 3:-1:1)
    @test v == rot180(rect)
    v = @inferred Augmentor.unroll_applylazy(ops, view(cameras,:,:,1))
    @test v === view(cameras, 512:-1:1, 512:-1:1, 1)
    @test v == rot180(camera)
end

ops = (Rotate90(), Rotate270())
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor.unroll_applyaffine(ops, rect)
    @test typeof(wv) === typeof(invwarpedview(rect, Augmentor.toaffinemap(NoOp(),rect), Flat()))
    @test wv == rect
    wv = @inferred Augmentor.unroll_applylazy(ops, Augmentor.prepareaffine(rect))
    @test typeof(wv) === typeof(invwarpedview(rect, Augmentor.toaffinemap(NoOp(),rect), Flat()))
    @test wv == rect
    img = @inferred Augmentor.applyeager(Resize(4,4), wv)
    @test img == imresize(rect, (4,4))
    v = @inferred Augmentor.unroll_applylazy(ops, view(cameras,:,:,1))
    @test v === view(cameras, 1:1:512, 1:1:512, 1)
    @test v == camera
    v = @inferred Augmentor.unroll_applylazy(ops, rect)
    @test v === view(rect, 1:1:2, 1:1:3)
    @test v == rect
    img = @inferred Augmentor.applyeager(Resize(4,4), v)
    @test img == imresize(rect, (4,4))
end

ops = (Rotate90(), Resize(3,3))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor.unroll_applyaffine(ops, square)
    @test typeof(wv) === typeof(view(invwarpedview(square, Augmentor.toaffinemap(NoOp(),square), Flat()),IdentityRange(1:2),IdentityRange(1:2)))
    @test wv == rotl90(square)
    wv = @inferred Augmentor.unroll_applylazy(ops, Augmentor.prepareaffine(square))
    @test typeof(wv) === typeof(view(invwarpedview(square, Augmentor.toaffinemap(NoOp(),square), Flat()),IdentityRange(1:2),IdentityRange(1:2)))
    @test wv == rotl90(square)
end

ops = (Rotate90(), Resize(2,2))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor.unroll_applyaffine(ops, square)
    @test typeof(wv) === typeof(view(invwarpedview(square, Augmentor.toaffinemap(NoOp(),square), Flat()),IdentityRange(1:2),IdentityRange(1:2)))
    @test wv == imresize(rotl90(square), 2, 2)
    wv = @inferred Augmentor.unroll_applylazy(ops, Augmentor.prepareaffine(square))
    @test typeof(wv) === typeof(view(invwarpedview(square, Augmentor.toaffinemap(NoOp(),square), Flat()),IdentityRange(1:2),IdentityRange(1:2)))
    @test wv == imresize(rotl90(square), 2, 2)
end

ops = (Rotate90(), Resize(5,9))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor.unroll_applyaffine(ops, square)
    @test typeof(wv) === typeof(view(invwarpedview(square, Augmentor.toaffinemap(NoOp(),square), Flat()),IdentityRange(1:2),IdentityRange(1:2)))
    @test wv == imresize(rotl90(square), 5, 9)
    wv = @inferred Augmentor.unroll_applylazy(ops, Augmentor.prepareaffine(square))
    @test typeof(wv) === typeof(view(invwarpedview(square, Augmentor.toaffinemap(NoOp(),square), Flat()),IdentityRange(1:2),IdentityRange(1:2)))
    @test wv == imresize(rotl90(square), 5, 9)
end

ops = (Rotate(-90), Rotate90())
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor.unroll_applyaffine(ops, rect)
    @test typeof(wv) === typeof(invwarpedview(rect, Augmentor.toaffinemap(NoOp(),rect), Flat()))
    @test wv == rect
    wv2 = @inferred Augmentor.unroll_applylazy(ops, rect)
    @test typeof(wv2) == typeof(wv)
    @test wv2 == rect
end

ops = (Rotate(-90), Crop(1:2,1:3), Rotate90()) # affine forces affine
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor.unroll_applyaffine(ops, rect)
    @test typeof(wv) === typeof(view(invwarpedview(rect, Augmentor.toaffinemap(NoOp(),rect), Flat()),IdentityRange(1:2),IdentityRange(1:2)))
    wv2 = @inferred Augmentor.unroll_applylazy(ops, rect)
    @test typeof(wv2) == typeof(wv)
end

ops = (Rotate90(), Rotate270(), Rotate180())
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor.unroll_applyaffine(ops, rect)
    @test typeof(wv) === typeof(invwarpedview(rect, Augmentor.toaffinemap(NoOp(),rect), Flat()))
    @test wv[1:2,1:3] == rot180(rect)
    wv2 = @inferred Augmentor.unroll_applylazy(ops, Augmentor.prepareaffine(rect))
    @test typeof(wv2) === typeof(invwarpedview(rect, Augmentor.toaffinemap(NoOp(),rect), Flat()))
    @test wv2 == wv
    v = @inferred Augmentor.unroll_applylazy(ops, rect)
    @test v === view(rect, 2:-1:1, 3:-1:1)
    @test v == rot180(rect)
end

ops = (Rotate180(), Either((Rotate90(), Rotate270()), (1,0)))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor.unroll_applyaffine(ops, square)
    @test typeof(wv) === typeof(invwarpedview(rect, Augmentor.toaffinemap(NoOp(),square), Flat()))
    r1 = invwarpedview(square, Augmentor.toaffinemap(Rotate180(),square), Flat())
    @test wv == invwarpedview(r1, Augmentor.toaffinemap(Rotate90(), r1))
    wv2 = @inferred Augmentor.unroll_applylazy(ops, Augmentor.prepareaffine(square))
    @test wv2 == wv
    v = @inferred Augmentor.unroll_applylazy(ops, rect)
    @test v === view(permuteddimsview(rect, (2,1)), 1:1:3, 2:-1:1)
    @test v == rotl90(rot180(rect))
end

ops = (Crop(1:2,2:3), Either((Rotate90(), Rotate270()), (1,0)))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor.unroll_applyaffine(ops, square)
    @test typeof(wv) <: SubArray
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === square
    @test parent(copy(wv)) == rotl90(view(square, 1:2, 2:3))
    wv2 = @inferred Augmentor.unroll_applylazy(ops, Augmentor.prepareaffine(square))
    @test wv2 == wv
    @test typeof(wv2) == typeof(wv)
    v = @inferred Augmentor.unroll_applylazy(ops, square)
    @test v === view(permuteddimsview(square,(2,1)), 3:-1:2, 1:1:2)
    @test v == rotl90(view(square, 1:2, 2:3))
end

ops = (Rotate180(), CropNative(1:2,2:3))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor.unroll_applyaffine(ops, square)
    @test typeof(wv) <: SubArray
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === square
    @test wv == view(rot180(square), IdentityRange(1:2), IdentityRange(2:3))
    wv2 = @inferred Augmentor.unroll_applylazy(ops, Augmentor.prepareaffine(square))
    @test wv2 == wv
    @test typeof(wv2) == typeof(wv)
    v = @inferred Augmentor.unroll_applylazy(ops, square)
    @test v === view(square, 3:-1:2, 2:-1:1)
    @test v == view(rot180(square), 1:2, 2:3)
end

ops = (Rotate180(), ElasticDistortion(5))
@testset "$(str_showcompact(ops))" begin
    @test_throws MethodError Augmentor.unroll_applyaffine(ops, square)
    v = @inferred Augmentor.unroll_applylazy(ops, square)
    @test v isa Augmentor.DistortedView
    @test parent(v) === view(square, 3:-1:1, 3:-1:1)
end

ops = (Rotate180(), CropSize(2,2))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor.unroll_applyaffine(ops, square)
    @test typeof(wv) <: SubArray
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === square
    @test wv == view(rot180(square), IdentityRange(1:2), IdentityRange(2:3))
    wv2 = @inferred Augmentor.unroll_applylazy(ops, Augmentor.prepareaffine(square))
    @test wv2 == wv
    @test typeof(wv2) == typeof(wv)
    v = @inferred Augmentor.unroll_applylazy(ops, square)
    @test v === view(square, 3:-1:2, 3:-1:2)
    @test v == view(rot180(square), 1:2, 1:2)
end

ops = (Either((Rotate90(),Rotate270()),(1,0)), Crop(20:30,100:150), Either((Rotate90(),Rotate270()),(0,1)))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor.unroll_applyaffine(ops, camera)
    @test typeof(wv) <: SubArray
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === camera
    @test parent(copy(wv)) == rotr90(view(rotl90(camera), 20:30, 100:150))
    v = @inferred Augmentor.unroll_applylazy(ops, camera)
    @test v === view(camera, 100:1:150, 483:1:493)
    @test v == parent(copy(wv))
    @test v == rotr90(view(rotl90(camera), 20:30, 100:150))
end
