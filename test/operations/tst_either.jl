@test (Either <: Augmentor.AffineOperation) == false

@testset "constructor" begin
    @test_throws ArgumentError Either()
    @test_throws ArgumentError Either(())
    @test_throws ArgumentError Either((NoOp(),),(0,))
    @test_throws ArgumentError Either((NoOp(),),(-1,))
    @test_throws MethodError Either((NoOp(),),(1,1))
    let op = @inferred Either(Rotate90(), 0.3)
        @test op.operations === (Rotate90(), NoOp())
        @test op.chances === @SVector([0.3,0.7])
        @test op.cum_chances === @SVector([0.3,1.0])
    end
    let op = @inferred Either(Rotate90())
        @test op.operations === (Rotate90(), NoOp())
        @test op.chances === @SVector([0.5,0.5])
        @test op.cum_chances === @SVector([0.5,1.0])
    end
    let op = @inferred Either(1 => Rotate90(), 2 => Rotate180(), 1 => Rotate270())
        @test op.operations === (Rotate90(),Rotate180(),Rotate270())
        @test op.chances === @SVector([0.25,0.5,0.25])
        @test op.cum_chances === @SVector([0.25,0.75,1.])
    end
    let op = @inferred Either((Rotate90(),Rotate180(),Rotate270()), (0.1,0.7,0.2))
        @test op.operations === (Rotate90(),Rotate180(),Rotate270())
        @test op.chances === @SVector([0.1,0.7,0.2])
        @test op.cum_chances ≈ @SVector([0.1,0.8,1.])
    end
    let op = @inferred Either((Rotate90(),Rotate180(),Rotate270()))
        @test op.operations === (Rotate90(),Rotate180(),Rotate270())
        @test op.chances ≈ @SVector([1/3,1/3,1/3])
        @test op.cum_chances ≈ @SVector([1/3,2/3,3/3])
    end
    let op = Either(Rotate90(), Rotate180(), Rotate270(), chances = [1,7,2])
        @test op.operations === (Rotate90(),Rotate180(),Rotate270())
        @test op.chances === @SVector([0.1,0.7,0.2])
        @test op.cum_chances ≈ @SVector([0.1,0.8,1.])
    end
    let op = @inferred Either(Rotate90(),Rotate180(),Rotate270())
        @test op.operations === (Rotate90(),Rotate180(),Rotate270())
        @test op.chances ≈ @SVector([1/3,1/3,1/3])
        @test op.cum_chances ≈ @SVector([1/3,2/3,3/3])
    end
    let op = @inferred(Rotate90()*Rotate180()*Rotate270())
        @test op.operations === (Rotate90(),Rotate180(),Rotate270())
        @test op.chances ≈ @SVector([1/3,1/3,1/3])
        @test op.cum_chances ≈ @SVector([1/3,2/3,3/3])
    end
    let op = @inferred((1=>Rotate90())*(2=>Rotate180())*(1=>Rotate270()))
        @test op.operations === (Rotate90(),Rotate180(),Rotate270())
        @test op.chances ≈ @SVector([1/4,2/4,1/4])
        @test op.cum_chances ≈ @SVector([1/4,3/4,4/4])
    end
end

@testset "show" begin
    @test str_show(Either((Rotate90(),Rotate270(),NoOp()), (0.2,0.3,0.5))) == """
    Augmentor.Either (1 out of 3 operation(s)):
      - 20% chance to: Rotate 90 degree
      - 30% chance to: Rotate 270 degree
      - 50% chance to: No operation"""
    @test str_showcompact(Either((Rotate90(),Rotate270(),NoOp()), (0.2,0.3,0.5))) ==
        "Either: (20%) Rotate 90 degree. (30%) Rotate 270 degree. (50%) No operation."
    @test str_show(Either((Rotate90(),Rotate270(),NoOp()), (0.15,0.8,0.05))) == """
    Augmentor.Either (1 out of 3 operation(s)):
      - 15% chance to: Rotate 90 degree
      - 80% chance to: Rotate 270 degree
      -  5% chance to: No operation"""
    @test str_showcompact(Either((Rotate90(),Rotate270(),NoOp()), (0.15,0.8,0.05))) ==
        "Either: (15%) Rotate 90 degree. (80%) Rotate 270 degree. (5%) No operation."
    @test str_show(Either((Rotate90(),Rotate270(),NoOp()), (0.155,0.8,0.045))) == """
    Augmentor.Either (1 out of 3 operation(s)):
      - 15.5% chance to: Rotate 90 degree
      - 80.0% chance to: Rotate 270 degree
      -  4.5% chance to: No operation"""
    @test str_showcompact(Either((Rotate90(),Rotate270(),NoOp()), (0.155,0.8,0.045))) ==
        "Either: (16%) Rotate 90 degree. (80%) Rotate 270 degree. (4%) No operation."
        @test str_showconst(Either(Rotate90(), Rotate270(), NoOp())) == "Rotate90() * Rotate270() * NoOp()"
        @test str_showconst(Either((Rotate90(), Rotate270(), NoOp()),(1,1,2))) == "(0.25=>Rotate90()) * (0.25=>Rotate270()) * (0.5=>NoOp())"
        @test str_showconst(Either((Rotate90(), NoOp()),(1,2))) == "(0.333=>Rotate90()) * (0.667=>NoOp())"
end

@testset "eager" begin
    @test_throws MethodError Augmentor.applyeager(Either(Rotate90(),NoOp()), nothing)
    for img in (rect, OffsetArray(rect, -2, -1), view(rect, IdentityRange(1:2), IdentityRange(1:3)))
        op = @inferred Either((Rotate90(),Rotate270()), (1,0))
        @test @inferred(Augmentor.supports_eager(op)) === true
        @test @inferred(Augmentor.applyeager(op, img)) == rotl90(rect)
        @test typeof(Augmentor.applyeager(op, img)) <: Array
        op = @inferred Either((Rotate90(),Rotate270(),Crop(1:2,2:3)), (0,1,0))
        @test @inferred(Augmentor.supports_eager(op)) === true
        @test @inferred(Augmentor.applyeager(op, img)) == rotr90(rect)
        @test typeof(Augmentor.applyeager(op, img)) <: Array
        op = @inferred Either((Rotate90(),Rotate270(),NoOp()), (0,0,1))
        @test @inferred(Augmentor.supports_eager(op)) === true
        if typeof(img) <: SubArray
            @test @inferred(Augmentor.applyeager(op, img)) == rect
            @test typeof(Augmentor.applyeager(op, img)) <: Array
        else
            @test @inferred(Augmentor.applyeager(op, img)) === rect
        end
        op = @inferred Either((Rotate90(),Rotate270(),Crop(1:2,2:3)), (0,0,1))
        @test @inferred(Augmentor.supports_eager(op)) === true
        @test @inferred(Augmentor.applyeager(op, img)) == rect[1:2,2:3]
        @test_throws MethodError Augmentor.applylazy(op, rect)
        @test_throws MethodError Augmentor.applyaffine(op, rect)
        @test_throws MethodError Augmentor.applyview(op, rect)
        @test_throws MethodError Augmentor.applystepview(op, rect)
        @test_throws MethodError Augmentor.applypermute(op, rect)
        op = @inferred Either((Rotate90(),Zoom(.8)), (1,0))
        @test @inferred(Augmentor.supports_eager(op)) === true
        @test @inferred(Augmentor.applyeager(op, img)) == rotl90(rect)
        @test typeof(Augmentor.applyeager(op, img)) <: Array
        op = @inferred Either((Rotate90(),FlipX()), (1,0))
        @test @inferred(Augmentor.supports_eager(op)) === true
        @test @inferred(Augmentor.applyeager(op, img)) == rotl90(rect)
        @test typeof(Augmentor.applyeager(op, img)) <: Array
        op = @inferred Either((Rotate90(),FlipX()), (0,1))
        @test @inferred(Augmentor.supports_eager(op)) === true
        @test @inferred(Augmentor.applyeager(op, img)) == flipdim(rect,2)
        @test typeof(Augmentor.applyeager(op, img)) <: Array
        op = @inferred Either((Rotate90(),FlipY()), (0,1))
        @test @inferred(Augmentor.supports_eager(op)) === true
        @test @inferred(Augmentor.applyeager(op, img)) == flipdim(rect,1)
        @test typeof(Augmentor.applyeager(op, img)) <: Array
        op = @inferred Either((Rotate90(),Resize(5,5)), (0,1))
        @test @inferred(Augmentor.supports_eager(op)) === true
        @test @inferred(Augmentor.applyeager(op, img)) == imresize(rect,5,5)
        @test typeof(Augmentor.applyeager(op, img)) <: Array
        op = @inferred Either((Crop(1:2,1:2),Resize(5,5)), (0,1))
        @test @inferred(Augmentor.supports_eager(op)) === true
        @test @inferred(Augmentor.applyeager(op, img)) == imresize(rect,5,5)
        @test typeof(Augmentor.applyeager(op, img)) <: Array
    end
end

@testset "affine" begin
    let op = @inferred Either((Rotate90(),Rotate(-90)), (1,0))
        @test @inferred(Augmentor.isaffine(op)) === true
        @test @inferred(Augmentor.supports_lazy(op)) === true
        @test @inferred(Augmentor.supports_affine(op)) === true
        @test @inferred(Augmentor.supports_view(op)) === false
        @test @inferred(Augmentor.supports_stepview(op)) === false
        @test @inferred(Augmentor.supports_permute(op)) === false
        @test_throws MethodError Augmentor.applyaffine(op, nothing)
        @test @inferred(Augmentor.toaffine(op, rect)) ≈ AffineMap([6.12323e-17 -1.0; 1.0 6.12323e-17], [3.5,0.5])
        wv = @inferred Augmentor.applyaffine(op, Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test wv == rotl90(square)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    let op = @inferred Either((Rotate90(),Rotate270()), (1,0))
        @test @inferred(Augmentor.isaffine(op)) === true
        @test @inferred(Augmentor.supports_lazy(op)) === true
        @test @inferred(Augmentor.supports_affine(op)) === true
        @test @inferred(Augmentor.supports_view(op)) === false
        @test @inferred(Augmentor.supports_stepview(op)) === false
        @test @inferred(Augmentor.supports_permute(op)) === true
        @test_throws MethodError Augmentor.applyaffine(op, nothing)
        @test @inferred(Augmentor.toaffine(op, rect)) ≈ AffineMap([6.12323e-17 -1.0; 1.0 6.12323e-17], [3.5,0.5])
        wv = @inferred Augmentor.applyaffine(op, Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test wv == rotl90(square)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    let op = @inferred Either((Rotate180(),FlipX(),FlipY()), (0,1,0))
        @test @inferred(Augmentor.isaffine(op)) === true
        @test @inferred(Augmentor.supports_lazy(op)) === true
        @test @inferred(Augmentor.supports_affine(op)) === true
        @test @inferred(Augmentor.supports_view(op)) === false
        @test @inferred(Augmentor.supports_stepview(op)) === true
        @test @inferred(Augmentor.supports_permute(op)) === false
        @test_throws MethodError Augmentor.applyaffine(op, nothing)
        @test @inferred(Augmentor.toaffine(op, rect)) ≈ AffineMap([1. 0.; 0. -1.], [0,4])
        wv = @inferred Augmentor.applyaffine(op, Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test wv == flipdim(square,2)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    let op = @inferred Either((Rotate90(),FlipY()), (0,1))
        @test @inferred(Augmentor.isaffine(op)) === true
        @test @inferred(Augmentor.supports_lazy(op)) === true
        @test @inferred(Augmentor.supports_affine(op)) === true
        @test @inferred(Augmentor.supports_view(op)) === false
        @test @inferred(Augmentor.supports_stepview(op)) === false
        @test @inferred(Augmentor.supports_permute(op)) === false
        @test_throws MethodError Augmentor.applyaffine(op, nothing)
        @test @inferred(Augmentor.toaffine(op, rect)) ≈ AffineMap([-1. 0.; 0. 1.], [3,0])
        wv = @inferred Augmentor.applyaffine(op, Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test wv == flipdim(square,1)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    let op = @inferred Either((Rotate90(),Rotate270()), (0,1))
        @test @inferred(Augmentor.isaffine(op)) === true
        @test @inferred(Augmentor.supports_lazy(op)) === true
        @test @inferred(Augmentor.supports_affine(op)) === true
        @test @inferred(Augmentor.supports_view(op)) === false
        @test @inferred(Augmentor.supports_stepview(op)) === false
        @test @inferred(Augmentor.supports_permute(op)) === true
        @test_throws MethodError Augmentor.applyaffine(op, nothing)
        @test @inferred(Augmentor.toaffine(op, rect)) ≈ AffineMap([6.12323e-17 1.0; -1.0 6.12323e-17], [-0.5,3.5])
        wv = @inferred Augmentor.applyaffine(op, Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test wv == rotr90(square)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    for op = (@inferred(Rotate90(1)), @inferred(Either((Rotate90(),Scale(0.8)),(1,0))))
        @test @inferred(Augmentor.isaffine(op)) === true
        @test @inferred(Augmentor.supports_lazy(op)) === true
        @test @inferred(Augmentor.supports_affine(op)) === true
        @test @inferred(Augmentor.supports_view(op)) === false
        @test @inferred(Augmentor.supports_stepview(op)) === false
        @test @inferred(Augmentor.supports_permute(op)) === false
        @test_throws MethodError Augmentor.applyaffine(op, nothing)
        @test @inferred(Augmentor.toaffine(op, rect)) ≈ AffineMap([6.12323e-17 -1.0; 1.0 6.12323e-17], [3.5,0.5])
        wv = @inferred Augmentor.applyaffine(op, Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test wv == rotl90(square)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
        wv2 = @inferred Augmentor.applylazy(op, square)
        @test parent(wv2).itp.coefs === square
        @test wv2 == rotl90(square)
        @test typeof(wv2) == typeof(wv)
    end
    let op = @inferred Either((Rotate90(),Rotate270(),Crop(1:2,1:2)))
        @test @inferred(Augmentor.isaffine(op)) === false
        @test @inferred(Augmentor.supports_lazy(op)) === false
        @test @inferred(Augmentor.supports_affine(op)) === false
        @test @inferred(Augmentor.supports_view(op)) === false
        @test @inferred(Augmentor.supports_stepview(op)) === false
        @test @inferred(Augmentor.supports_permute(op)) === false
        @test_throws MethodError Augmentor.toaffine(op, nothing)
        @test_throws MethodError Augmentor.toaffine(op, rect)
        @test_throws MethodError Augmentor.applyaffine(op, Augmentor.prepareaffine(square))
    end
    let op = @inferred Either((Rotate90(),Rotate270(),CropSize(2,2)))
        @test @inferred(Augmentor.isaffine(op)) === false
        @test @inferred(Augmentor.supports_lazy(op)) === false
        @test @inferred(Augmentor.supports_affine(op)) === false
        @test @inferred(Augmentor.supports_view(op)) === false
        @test @inferred(Augmentor.supports_stepview(op)) === false
        @test @inferred(Augmentor.supports_permute(op)) === false
        @test_throws MethodError Augmentor.toaffine(op, nothing)
        @test_throws MethodError Augmentor.toaffine(op, rect)
        @test_throws MethodError Augmentor.applyaffine(op, Augmentor.prepareaffine(square))
    end
    let op = @inferred Either((Rotate90(),Zoom(.8)))
        @test @inferred(Augmentor.isaffine(op)) === false
        @test @inferred(Augmentor.supports_lazy(op)) === false
        @test @inferred(Augmentor.supports_affine(op)) === false
        @test @inferred(Augmentor.supports_view(op)) === false
        @test @inferred(Augmentor.supports_stepview(op)) === false
        @test @inferred(Augmentor.supports_permute(op)) === false
        @test_throws MethodError Augmentor.toaffine(op, nothing)
        @test_throws MethodError Augmentor.toaffine(op, rect)
        @test_throws MethodError Augmentor.applyaffine(op, Augmentor.prepareaffine(square))
    end
    let op = @inferred Either((Rotate90(),Resize(2,3)))
        @test @inferred(Augmentor.isaffine(op)) === false
        @test @inferred(Augmentor.supports_lazy(op)) === false
        @test @inferred(Augmentor.supports_affine(op)) === false
        @test @inferred(Augmentor.supports_view(op)) === false
        @test @inferred(Augmentor.supports_stepview(op)) === false
        @test @inferred(Augmentor.supports_permute(op)) === false
        @test_throws MethodError Augmentor.toaffine(op, nothing)
        @test_throws MethodError Augmentor.toaffine(op, rect)
        @test_throws MethodError Augmentor.applyaffine(op, Augmentor.prepareaffine(square))
    end
    let op = @inferred Either((Crop(1:2,1:2),Resize(2,3)))
        @test @inferred(Augmentor.isaffine(op)) === false
        @test @inferred(Augmentor.supports_lazy(op)) === false
        @test @inferred(Augmentor.supports_affine(op)) === false
        @test @inferred(Augmentor.supports_view(op)) === false
        @test @inferred(Augmentor.supports_stepview(op)) === false
        @test @inferred(Augmentor.supports_permute(op)) === false
        @test_throws MethodError Augmentor.toaffine(op, nothing)
        @test_throws MethodError Augmentor.toaffine(op, rect)
        @test_throws MethodError Augmentor.applyaffine(op, Augmentor.prepareaffine(square))
    end
end

@testset "view" begin
    let op = @inferred Either((NoOp(),Crop(1:2,2:3)), (1,0))
        @test @inferred(Augmentor.isaffine(op)) === false
        @test @inferred(Augmentor.supports_lazy(op)) === true
        @test @inferred(Augmentor.supports_affine(op)) === false
        @test @inferred(Augmentor.supports_view(op)) === true
        @test @inferred(Augmentor.supports_stepview(op)) === true
        @test @inferred(Augmentor.supports_permute(op)) === false
        @test @inferred(Augmentor.applyview(op, rect)) === view(rect, IdentityRange(1:2), IdentityRange(1:3))
        @test @inferred(Augmentor.applylazy(op, rect)) === view(rect, IdentityRange(1:2), IdentityRange(1:3))
    end
    let op = @inferred Either((NoOp(),Crop(1:2,2:3)), (0,1))
        @test @inferred(Augmentor.isaffine(op)) === false
        @test @inferred(Augmentor.supports_lazy(op)) === true
        @test @inferred(Augmentor.supports_affine(op)) === false
        @test @inferred(Augmentor.supports_view(op)) === true
        @test @inferred(Augmentor.supports_stepview(op)) === true
        @test @inferred(Augmentor.supports_permute(op)) === false
        @test @inferred(Augmentor.applyview(op, rect)) === view(rect, IdentityRange(1:2), IdentityRange(2:3))
        @test @inferred(Augmentor.applylazy(op, rect)) === view(rect, IdentityRange(1:2), IdentityRange(2:3))
    end
    let op = @inferred Either((Crop(1:2,2:4),CropSize(2,3)), (0,1))
        @test @inferred(Augmentor.isaffine(op)) === false
        @test @inferred(Augmentor.supports_lazy(op)) === true
        @test @inferred(Augmentor.supports_affine(op)) === false
        @test @inferred(Augmentor.supports_view(op)) === true
        @test @inferred(Augmentor.supports_stepview(op)) === true
        @test @inferred(Augmentor.supports_permute(op)) === false
        @test @inferred(Augmentor.applyview(op, rect)) === view(rect, IdentityRange(1:2), IdentityRange(1:3))
        @test @inferred(Augmentor.applylazy(op, rect)) === view(rect, IdentityRange(1:2), IdentityRange(1:3))
    end
end

@testset "stepview" begin
    let op = @inferred Either((Rotate180(),FlipX()), (1,0))
        @test @inferred(Augmentor.isaffine(op)) === true
        @test @inferred(Augmentor.supports_lazy(op)) === true
        @test @inferred(Augmentor.supports_affine(op)) === true
        @test @inferred(Augmentor.supports_view(op)) === false
        @test @inferred(Augmentor.supports_stepview(op)) === true
        @test @inferred(Augmentor.supports_permute(op)) === false
        @test_throws MethodError Augmentor.applylazy(op, nothing)
        @test_throws MethodError Augmentor.applystepview(op, nothing)
        v = @inferred Augmentor.applylazy(op, rect)
        @test v === @inferred(Augmentor.applystepview(op, rect))
        @test v === view(rect,2:-1:1,3:-1:1)
        @test v == rot180(rect)
        @test typeof(v) <: SubArray
    end
    let op = @inferred Either((Rotate180(),FlipX()), (0,1))
        @test @inferred(Augmentor.isaffine(op)) === true
        @test @inferred(Augmentor.supports_lazy(op)) === true
        @test @inferred(Augmentor.supports_affine(op)) === true
        @test @inferred(Augmentor.supports_view(op)) === false
        @test @inferred(Augmentor.supports_stepview(op)) === true
        @test @inferred(Augmentor.supports_permute(op)) === false
        @test_throws MethodError Augmentor.applylazy(op, nothing)
        @test_throws MethodError Augmentor.applystepview(op, nothing)
        v = @inferred Augmentor.applylazy(op, rect)
        @test v === @inferred(Augmentor.applystepview(op, rect))
        @test v === view(rect,1:1:2,3:-1:1)
        @test v == flipdim(rect,2)
        @test typeof(v) <: SubArray
    end
    let op = @inferred Either((FlipY(),FlipX()), (1,0))
        @test @inferred(Augmentor.isaffine(op)) === true
        @test @inferred(Augmentor.supports_lazy(op)) === true
        @test @inferred(Augmentor.supports_affine(op)) === true
        @test @inferred(Augmentor.supports_view(op)) === false
        @test @inferred(Augmentor.supports_stepview(op)) === true
        @test @inferred(Augmentor.supports_permute(op)) === false
        @test_throws MethodError Augmentor.applylazy(op, nothing)
        @test_throws MethodError Augmentor.applystepview(op, nothing)
        v = @inferred Augmentor.applylazy(op, rect)
        @test v === @inferred(Augmentor.applystepview(op, rect))
        @test v === view(rect,2:-1:1,1:1:3)
        @test v == flipdim(rect,1)
        @test typeof(v) <: SubArray
    end
    let op = @inferred Either((Rotate180(),NoOp()), (1,0))
        @test @inferred(Augmentor.isaffine(op)) === true
        @test @inferred(Augmentor.supports_lazy(op)) === true
        @test @inferred(Augmentor.supports_affine(op)) === true
        @test @inferred(Augmentor.supports_view(op)) === false
        @test @inferred(Augmentor.supports_stepview(op)) === true
        @test @inferred(Augmentor.supports_permute(op)) === false
        @test_throws MethodError Augmentor.applylazy(op, nothing)
        @test_throws MethodError Augmentor.applystepview(op, nothing)
        v = @inferred Augmentor.applylazy(op, rect)
        @test v === @inferred(Augmentor.applystepview(op, rect))
        @test v === view(rect,2:-1:1,3:-1:1)
        @test v == rot180(rect)
        @test typeof(v) <: SubArray
    end
    let op = @inferred Either((Rotate180(),NoOp(),Crop(1:2,2:3)),(0,1,0))
        @test @inferred(Augmentor.isaffine(op)) === false
        @test @inferred(Augmentor.supports_lazy(op)) === true
        @test @inferred(Augmentor.supports_affine(op)) === false
        @test @inferred(Augmentor.supports_view(op)) === false
        @test @inferred(Augmentor.supports_stepview(op)) === true
        @test @inferred(Augmentor.supports_permute(op)) === false
        @test_throws MethodError Augmentor.applylazy(op, nothing)
        @test_throws MethodError Augmentor.applystepview(op, nothing)
        v = @inferred Augmentor.applylazy(op, rect)
        @test v === @inferred(Augmentor.applystepview(op, rect))
        @test v === view(rect,1:1:2,1:1:3)
        @test v == rect
        @test typeof(v) <: SubArray
    end
    let op = @inferred Either((Rotate180(),NoOp(),Crop(1:2,2:3)),(0,0,1))
        @test @inferred(Augmentor.isaffine(op)) === false
        @test @inferred(Augmentor.supports_lazy(op)) === true
        @test @inferred(Augmentor.supports_affine(op)) === false
        @test @inferred(Augmentor.supports_view(op)) === false
        @test @inferred(Augmentor.supports_stepview(op)) === true
        @test @inferred(Augmentor.supports_permute(op)) === false
        @test_throws MethodError Augmentor.applylazy(op, nothing)
        @test_throws MethodError Augmentor.applystepview(op, nothing)
        v = @inferred Augmentor.applylazy(op, rect)
        @test v === @inferred(Augmentor.applystepview(op, rect))
        @test v === view(rect,1:1:2,2:1:3)
        @test typeof(v) <: SubArray
    end
    let op = @inferred Either((Rotate180(),CropSize(2,3)),(0,1))
        @test @inferred(Augmentor.isaffine(op)) === false
        @test @inferred(Augmentor.supports_lazy(op)) === true
        @test @inferred(Augmentor.supports_affine(op)) === false
        @test @inferred(Augmentor.supports_view(op)) === false
        @test @inferred(Augmentor.supports_stepview(op)) === true
        @test @inferred(Augmentor.supports_permute(op)) === false
        @test_throws MethodError Augmentor.applylazy(op, nothing)
        @test_throws MethodError Augmentor.applystepview(op, nothing)
        v = @inferred Augmentor.applylazy(op, square)
        @test v === @inferred(Augmentor.applystepview(op, square))
        @test v === view(square,1:1:2,1:1:3)
        @test typeof(v) <: SubArray
    end
end

@testset "permute" begin
    let op = @inferred Either((Rotate90(),Rotate270()), (1,0))
        @test @inferred(Augmentor.isaffine(op)) === true
        @test @inferred(Augmentor.supports_lazy(op)) === true
        @test @inferred(Augmentor.supports_affine(op)) === true
        @test @inferred(Augmentor.supports_view(op)) === false
        @test @inferred(Augmentor.supports_stepview(op)) === false
        @test @inferred(Augmentor.supports_permute(op)) === true
        @test_throws MethodError Augmentor.applylazy(op, nothing)
        @test_throws MethodError Augmentor.applypermute(op, nothing)
        v = @inferred Augmentor.applylazy(op, rect)
        @test v === @inferred(Augmentor.applypermute(op, rect))
        @test v === view(permuteddimsview(rect,(2,1)),3:-1:1,1:1:2)
        @test v == rotl90(rect)
        @test typeof(v) <: SubArray
    end
    let op = @inferred Either((Rotate90(),Rotate270()), (0,1))
        @test @inferred(Augmentor.isaffine(op)) === true
        @test @inferred(Augmentor.supports_lazy(op)) === true
        @test @inferred(Augmentor.supports_affine(op)) === true
        @test @inferred(Augmentor.supports_view(op)) === false
        @test @inferred(Augmentor.supports_stepview(op)) === false
        @test @inferred(Augmentor.supports_permute(op)) === true
        @test_throws MethodError Augmentor.applylazy(op, nothing)
        @test_throws MethodError Augmentor.applypermute(op, nothing)
        v = @inferred Augmentor.applylazy(op, rect)
        @test v === @inferred(Augmentor.applypermute(op, rect))
        @test v === view(permuteddimsview(rect,(2,1)),1:1:3,2:-1:1)
        @test v == rotr90(rect)
        @test typeof(v) <: SubArray
    end
end
