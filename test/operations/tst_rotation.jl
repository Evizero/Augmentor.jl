@testset "Rotate90" begin
    @test typeof(@inferred(Rotate90())) <: Rotate90 <: Augmentor.AffineOperation
    @testset "constructor" begin
        @test @inferred(Rotate90(0.7)) === Either(Rotate90(), 0.7)
        @test str_show(Rotate90()) == "Augmentor.Rotate90()"
        @test str_showcompact(Rotate90()) == "Rotate 90 degree"
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(Rotate90(), nothing)
        for img in (rect, OffsetArray(rect, -2, -1))
            @test @inferred(Augmentor.applyeager(Rotate90(), img)) == rotl90(rect)
            @test typeof(Augmentor.applyeager(Rotate90(), img)) <: Array
        end
    end
    @testset "affine" begin
        @test @inferred(Augmentor.isaffine(Rotate90)) === true
        @test @inferred(Augmentor.supports_affine(Rotate90)) === true
        @test_throws MethodError Augmentor.applyaffine(Rotate90(), nothing)
        @test @inferred(Augmentor.toaffine(Rotate90(), rect)) ≈ AffineMap([6.12323e-17 -1.0; 1.0 6.12323e-17], [3.5,0.5])
        wv = @inferred Augmentor.applyaffine(Rotate90(), Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test wv == rotl90(square)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "lazy" begin
        @test @inferred(Augmentor.supports_lazy(Rotate90)) === true
        v = @inferred Augmentor.applylazy(Rotate90(), rect)
        @test v === view(permuteddimsview(rect, (2,1)), 3:-1:1, 1:1:2)
        @test v == rotl90(rect)
        @test typeof(v) <: SubArray
    end
    @testset "view" begin
        @test @inferred(Augmentor.supports_view(Rotate90)) === false
    end
    @testset "stepview" begin
        @test @inferred(Augmentor.supports_stepview(Rotate90)) === false
    end
    @testset "permute" begin
        @test @inferred(Augmentor.supports_permute(Rotate90)) === true
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
        @test str_showcompact(Rotate180()) == "Rotate 180 degree"
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(Rotate180(), nothing)
        for img in (rect, OffsetArray(rect, -2, -1))
            @test @inferred(Augmentor.applyeager(Rotate180(), img)) == rot180(rect)
            @test typeof(Augmentor.applyeager(Rotate180(), img)) <: Array
        end
    end
    @testset "affine" begin
        @test @inferred(Augmentor.isaffine(Rotate180)) === true
        @test @inferred(Augmentor.supports_affine(Rotate180)) === true
        @test_throws MethodError Augmentor.applyaffine(Rotate180(), nothing)
        @test @inferred(Augmentor.toaffine(Rotate180(), rect)) ≈ AffineMap([-1.0 -1.22465e-16; 1.22465e-16 -1.0], [3.0,4.0])
        wv = @inferred Augmentor.applyaffine(Rotate180(), Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test wv[1:3,1:3] == rot180(square)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "lazy" begin
        @test @inferred(Augmentor.supports_lazy(Rotate180)) === true
        v = @inferred Augmentor.applylazy(Rotate180(), rect)
        @test v === view(rect, 2:-1:1, 3:-1:1)
        @test v == rot180(rect)
        @test typeof(v) <: SubArray
    end
    @testset "view" begin
        @test @inferred(Augmentor.supports_view(Rotate180)) === false
    end
    @testset "stepview" begin
        @test @inferred(Augmentor.supports_stepview(Rotate180)) === true
        v = @inferred Augmentor.applylazy(Rotate180(), rect)
        @test v === view(rect, 2:-1:1, 3:-1:1)
        @test v == rot180(rect)
        @test typeof(v) <: SubArray
    end
    @testset "permute" begin
        @test @inferred(Augmentor.supports_permute(Rotate180)) === false
    end
end

# --------------------------------------------------------------------

@testset "Rotate270" begin
    @test typeof(@inferred(Rotate270())) <: Rotate270 <: Augmentor.AffineOperation
    @testset "constructor" begin
        @test @inferred(Rotate270(0.7)) === Either(Rotate270(), 0.7)
        @test str_show(Rotate270()) == "Augmentor.Rotate270()"
        @test str_showcompact(Rotate270()) == "Rotate 270 degree"
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(Rotate270(), nothing)
        for img in (rect, OffsetArray(rect, -2, -1))
            @test @inferred(Augmentor.applyeager(Rotate270(), img)) == rotr90(rect)
            @test typeof(Augmentor.applyeager(Rotate270(), img)) <: Array
        end
    end
    @testset "affine" begin
        @test @inferred(Augmentor.isaffine(Rotate270)) === true
        @test @inferred(Augmentor.supports_affine(Rotate270)) === true
        @test_throws MethodError Augmentor.applyaffine(Rotate270(), nothing)
        @test @inferred(Augmentor.toaffine(Rotate270(), rect)) ≈ AffineMap([6.12323e-17 1.0; -1.0 6.12323e-17], [-0.5,3.5])
        wv = @inferred Augmentor.applyaffine(Rotate270(), Augmentor.prepareaffine(square))
        @test parent(wv).itp.coefs === square
        @test wv == rotr90(square)
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "lazy" begin
        @test @inferred(Augmentor.supports_lazy(Rotate270)) === true
        v = @inferred Augmentor.applylazy(Rotate270(), rect)
        @test v === view(permuteddimsview(rect, (2,1)), 1:1:3, 2:-1:1)
        @test v == rotr90(rect)
        @test typeof(v) <: SubArray
    end
    @testset "view" begin
        @test @inferred(Augmentor.supports_view(Rotate270)) === false
    end
    @testset "stepview" begin
        @test @inferred(Augmentor.supports_stepview(Rotate270)) === false
    end
    @testset "permute" begin
        @test @inferred(Augmentor.supports_permute(Rotate270)) === true
        v = @inferred Augmentor.applypermute(Rotate270(), rect)
        @test v === view(permuteddimsview(rect, (2,1)), 1:1:3, 2:-1:1)
        @test v == rotr90(rect)
        @test typeof(v) <: SubArray
        v2 = @inferred Augmentor.applypermute(Rotate270(), v)
        @test v2 === view(rect, 2:-1:1, 3:-1:1)
        @test v2 == rot180(rect)
    end
end
