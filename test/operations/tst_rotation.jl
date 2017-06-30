@testset "Rotate90" begin
    @test typeof(@inferred(Rotate90())) <: Rotate90 <: Augmentor.AffineOperation
    @testset "constructor" begin
        @test @inferred(Rotate90(0.7)) === Either(Rotate90(), 0.7)
        @test str_show(Rotate90()) == "Augmentor.Rotate90()"
        @test str_showconst(Rotate90()) == "Rotate90()"
        @test str_showcompact(Rotate90()) == "Rotate 90 degree"
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(Rotate90(), nothing)
        @test Augmentor.supports_eager(Rotate90) === true
        for img in (rect, OffsetArray(rect, -2, -1), view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applyeager(Rotate90(), img)) == rotl90(rect)
            @test typeof(Augmentor.applyeager(Rotate90(), img)) <: Array
        end
    end
    @testset "affine" begin
        @test Augmentor.supports_affine(Rotate90) === true
        @test_throws MethodError Augmentor.applyaffine(Rotate90(), nothing)
        @test @inferred(Augmentor.toaffinemap(Rotate90(), rect)) ≈ AffineMap([6.12323e-17 -1.0; 1.0 6.12323e-17], [3.5,0.5])
        wv = @inferred Augmentor.applyaffine(Rotate90(), Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test wv == rotl90(square)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "affineview" begin
        @test Augmentor.supports_affineview(Rotate90) === true
        @test_throws MethodError Augmentor.applyaffineview(Rotate90(), nothing)
        wv = @inferred Augmentor.applyaffineview(Rotate90(), Augmentor.prepareaffine(square))
        @test typeof(wv) <: SubArray{eltype(square),2}
        @test typeof(parent(wv)) <: InvWarpedView
        @test parent(parent(wv)).itp.coefs === square
        @test wv == rotl90(square)
    end
    @testset "lazy" begin
        @test Augmentor.supports_lazy(Rotate90) === true
        v = @inferred Augmentor.applylazy(Rotate90(), rect)
        @test v === view(permuteddimsview(rect, (2,1)), 3:-1:1, 1:1:2)
        @test v == rotl90(rect)
        @test typeof(v) <: SubArray
        v = @inferred Augmentor.applylazy(Rotate90(), view(square,1:2,1:3))
        @test v === view(permuteddimsview(square, (2,1)), 3:-1:1, 1:1:2)
        @test v == rotl90(rect)
        @test typeof(v) <: SubArray
        wv = @inferred Augmentor.applylazy(Rotate90(), Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test wv == rotl90(square)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "view" begin
        @test Augmentor.supports_view(Rotate90) === false
    end
    @testset "stepview" begin
        @test Augmentor.supports_stepview(Rotate90) === false
    end
    @testset "permute" begin
        @test Augmentor.supports_permute(Rotate90) === true
        v = @inferred Augmentor.applypermute(Rotate90(), rect)
        @test v === view(permuteddimsview(rect, (2,1)), 3:-1:1, 1:1:2)
        @test v == rotl90(rect)
        @test typeof(v) <: SubArray
        v2 = @inferred Augmentor.applypermute(Rotate90(), v)
        @test v2 === view(rect, 2:-1:1, 3:-1:1)
        @test v2 == rot180(rect)
    end
end

# --------------------------------------------------------------------

@testset "Rotate180" begin
    @test typeof(@inferred(Rotate180())) <: Rotate180 <: Augmentor.AffineOperation
    @testset "constructor" begin
        @test @inferred(Rotate180(0.7)) === Either(Rotate180(), 0.7)
        @test str_show(Rotate180()) == "Augmentor.Rotate180()"
        @test str_showconst(Rotate180()) == "Rotate180()"
        @test str_showcompact(Rotate180()) == "Rotate 180 degree"
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(Rotate180(), nothing)
        @test Augmentor.supports_eager(Rotate180) === true
        for img in (rect, OffsetArray(rect, -2, -1), view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applyeager(Rotate180(), img)) == rot180(rect)
            @test typeof(Augmentor.applyeager(Rotate180(), img)) <: Array
        end
    end
    @testset "affine" begin
        @test Augmentor.supports_affine(Rotate180) === true
        @test_throws MethodError Augmentor.applyaffine(Rotate180(), nothing)
        @test @inferred(Augmentor.toaffinemap(Rotate180(), rect)) ≈ AffineMap([-1.0 -1.22465e-16; 1.22465e-16 -1.0], [3.0,4.0])
        wv = @inferred Augmentor.applyaffine(Rotate180(), Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test wv[1:3,1:3] == rot180(square)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "affineview" begin
        @test Augmentor.supports_affineview(Rotate180) === true
        @test_throws MethodError Augmentor.applyaffineview(Rotate180(), nothing)
        wv = @inferred Augmentor.applyaffineview(Rotate180(), Augmentor.prepareaffine(square))
        @test typeof(wv) <: SubArray{eltype(square),2}
        @test typeof(parent(wv)) <: InvWarpedView
        @test parent(parent(wv)).itp.coefs === square
        @test wv[1:3,1:3] == rot180(square)
    end
    @testset "lazy" begin
        @test Augmentor.supports_lazy(Rotate180) === true
        v = @inferred Augmentor.applylazy(Rotate180(), rect)
        @test v === view(rect, 2:-1:1, 3:-1:1)
        @test v == rot180(rect)
        @test typeof(v) <: SubArray
        wv = @inferred Augmentor.applylazy(Rotate180(), Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test wv[1:3,1:3] == rot180(square)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "view" begin
        @test Augmentor.supports_view(Rotate180) === false
    end
    @testset "stepview" begin
        @test Augmentor.supports_stepview(Rotate180) === true
        v = @inferred Augmentor.applylazy(Rotate180(), rect)
        @test v === view(rect, 2:-1:1, 3:-1:1)
        @test v == rot180(rect)
        @test typeof(v) <: SubArray
        img = OffsetArray(rect,-2,1)
        v = @inferred Augmentor.applylazy(Rotate180(), img)
        @test v === view(img, 0:-1:-1, 4:-1:2)
        @test v == rot180(rect)
        @test typeof(v) <: SubArray
    end
    @testset "permute" begin
        @test Augmentor.supports_permute(Rotate180) === false
    end
end

# --------------------------------------------------------------------

@testset "Rotate270" begin
    @test typeof(@inferred(Rotate270())) <: Rotate270 <: Augmentor.AffineOperation
    @testset "constructor" begin
        @test @inferred(Rotate270(0.7)) === Either(Rotate270(), 0.7)
        @test str_show(Rotate270()) == "Augmentor.Rotate270()"
        @test str_showconst(Rotate270()) == "Rotate270()"
        @test str_showcompact(Rotate270()) == "Rotate 270 degree"
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(Rotate270(), nothing)
        @test Augmentor.supports_eager(Rotate270) === true
        for img in (rect, OffsetArray(rect, -2, -1), view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applyeager(Rotate270(), img)) == rotr90(rect)
            @test typeof(Augmentor.applyeager(Rotate270(), img)) <: Array
        end
    end
    @testset "affine" begin
        @test Augmentor.supports_affine(Rotate270) === true
        @test_throws MethodError Augmentor.applyaffine(Rotate270(), nothing)
        @test @inferred(Augmentor.toaffinemap(Rotate270(), rect)) ≈ AffineMap([6.12323e-17 1.0; -1.0 6.12323e-17], [-0.5,3.5])
        wv = @inferred Augmentor.applyaffine(Rotate270(), Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test wv == rotr90(square)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "affineview" begin
        @test Augmentor.supports_affineview(Rotate270) === true
        @test_throws MethodError Augmentor.applyaffineview(Rotate270(), nothing)
        wv = @inferred Augmentor.applyaffineview(Rotate270(), Augmentor.prepareaffine(square))
        @test typeof(wv) <: SubArray{eltype(square),2}
        @test typeof(parent(wv)) <: InvWarpedView
        @test parent(parent(wv)).itp.coefs === square
        @test wv == rotr90(square)
    end
    @testset "lazy" begin
        @test Augmentor.supports_lazy(Rotate270) === true
        v = @inferred Augmentor.applylazy(Rotate270(), rect)
        @test v === view(permuteddimsview(rect, (2,1)), 1:1:3, 2:-1:1)
        @test v == rotr90(rect)
        @test typeof(v) <: SubArray
        v = @inferred Augmentor.applylazy(Rotate270(), view(square,1:2,1:3))
        @test v === view(permuteddimsview(square, (2,1)), 1:1:3, 2:-1:1)
        @test v == rotr90(rect)
        @test typeof(v) <: SubArray
        wv = @inferred Augmentor.applylazy(Rotate270(), Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test wv == rotr90(square)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "view" begin
        @test Augmentor.supports_view(Rotate270) === false
    end
    @testset "stepview" begin
        @test Augmentor.supports_stepview(Rotate270) === false
    end
    @testset "permute" begin
        @test Augmentor.supports_permute(Rotate270) === true
        v = @inferred Augmentor.applypermute(Rotate270(), rect)
        @test v === view(permuteddimsview(rect, (2,1)), 1:1:3, 2:-1:1)
        @test v == rotr90(rect)
        @test typeof(v) <: SubArray
        v2 = @inferred Augmentor.applypermute(Rotate270(), v)
        @test v2 === view(rect, 2:-1:1, 3:-1:1)
        @test v2 == rot180(rect)
    end
end

# --------------------------------------------------------------------

@testset "Rotate" begin
    @test typeof(@inferred(Rotate(1))) <: Rotate <: Augmentor.AffineOperation
    @testset "constructor" begin
        @test_throws MethodError Rotate()
        @test_throws MethodError Rotate(:a)
        @test_throws MethodError Rotate([:a])
        @test_throws ArgumentError Rotate(3:1)
        @test @inferred(Rotate(0.7)) === Rotate(0.7:1:0.7)
        @test str_show(Rotate(0.7)) == "Augmentor.Rotate(0.7)"
        @test str_showconst(Rotate(0.7)) == "Rotate(0.7)"
        @test str_showcompact(Rotate(0.7)) == "Rotate 0.7 degree"
        @test @inferred(Rotate(10)) === Rotate(10:10)
        @test str_show(Rotate(10)) == "Augmentor.Rotate(10)"
        @test str_showconst(Rotate(10)) == "Rotate(10)"
        @test str_showcompact(Rotate(10)) == "Rotate 10 degree"
        op = @inferred(Rotate(-1:1))
        @test str_show(op) == "Augmentor.Rotate(-1:1)"
        @test str_showconst(op) == "Rotate(-1:1)"
        @test str_showcompact(op) == "Rotate by θ ∈ -1:1 degree"
        op = @inferred(Rotate([2,30]))
        @test op.degree == [2,30]
        @test str_show(op) == "Augmentor.Rotate([2, 30])"
        @test str_showconst(op) == "Rotate([2, 30])"
        @test str_showcompact(op) == "Rotate by θ ∈ [2, 30] degree"
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(Rotate(10), nothing)
        @test Augmentor.supports_eager(Rotate) === false
        # TODO: more tests
        for img in (square, OffsetArray(square, 0, 0), view(square, IdentityRange(1:3), IdentityRange(1:3)))
            @test @inferred(Augmentor.applyeager(Rotate(90), img)) == rotl90(square)
            @test typeof(Augmentor.applyeager(Rotate(90), img)) <: Array
            @test @inferred(Augmentor.applyeager(Rotate(-90), img)) == rotr90(square)
            @test typeof(Augmentor.applyeager(Rotate(-90), img)) <: Array
        end
    end
    @testset "affine" begin
        @test Augmentor.supports_affine(Rotate) === true
        @test_throws MethodError Augmentor.applyaffine(Rotate(90), nothing)
        @test @inferred(Augmentor.toaffinemap(Rotate(45), rect)) ≈ AffineMap([0.70710678118 -0.70710678118; 0.70710678118 0.70710678118], [1.85355339059,-0.47487373415])
        @test @inferred(Augmentor.toaffinemap(Rotate(90), rect)) ≈ AffineMap([6.12323e-17 -1.0; 1.0 6.12323e-17], [3.5,0.5])
        @test @inferred(Augmentor.toaffinemap(Rotate(-90), rect)) ≈ AffineMap([6.12323e-17 1.0; -1.0 6.12323e-17], [-0.5,3.5])
        wv = @inferred Augmentor.applyaffine(Rotate(90), Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test wv == rotl90(square)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
        wv = @inferred Augmentor.applyaffine(Rotate(-90), Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test wv == rotr90(square)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "affineview" begin
        @test Augmentor.supports_affineview(Rotate) === true
        @test_throws MethodError Augmentor.applyaffineview(Rotate(90), nothing)
        wv = @inferred Augmentor.applyaffineview(Rotate(90), Augmentor.prepareaffine(square))
        @test typeof(wv) <: SubArray{eltype(square),2}
        @test typeof(parent(wv)) <: InvWarpedView
        @test parent(parent(wv)).itp.coefs === square
        @test wv == rotl90(square)
        wv = @inferred Augmentor.applyaffineview(Rotate(-90), Augmentor.prepareaffine(square))
        @test typeof(wv) <: SubArray{eltype(square),2}
        @test typeof(parent(wv)) <: InvWarpedView
        @test parent(parent(wv)).itp.coefs === square
        @test wv == rotr90(square)
    end
    @testset "lazy" begin
        @test Augmentor.supports_lazy(Rotate(90)) === true
        wv = @inferred Augmentor.applylazy(Rotate(90), square)
        @test parent(wv).itp.coefs === square
        @test wv == rotl90(square)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
        wv = @inferred Augmentor.applylazy(Rotate(-90), square)
        @test parent(wv).itp.coefs === square
        @test wv == rotr90(square)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "view" begin
        @test Augmentor.supports_view(Rotate) === false
    end
    @testset "stepview" begin
        @test Augmentor.supports_stepview(Rotate) === false
    end
    @testset "permute" begin
        @test Augmentor.supports_permute(Rotate) === false
    end
end
