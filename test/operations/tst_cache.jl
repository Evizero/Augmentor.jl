@testset "CacheImage" begin
    @test (CacheImage <: Augmentor.AffineOperation) == false
    @test (CacheImage <: Augmentor.ImageOperation) == true
    @test typeof(@inferred(CacheImage())) <: CacheImage
    @test str_show(CacheImage()) == "Augmentor.CacheImage()"
    @test str_showconst(CacheImage()) == "CacheImage()"
    @test str_showcompact(CacheImage()) == "Cache into temporary buffer"

    @test @inferred(Augmentor.applyeager(CacheImage(),square)) === square

    v = view(square, :, :)
    img = @inferred Augmentor.applyeager(CacheImage(), v)
    @test typeof(img) <: Array
    @test eltype(img) == eltype(v)
    @test img !== square
    @test img == square

    o = OffsetArray(square, (-1,2))
    @test @inferred(Augmentor.applyeager(CacheImage(),o)) === o

    @test Augmentor.supports_eager(CacheImage) === true
    @test Augmentor.supports_lazy(CacheImage) === false
    @test Augmentor.supports_view(CacheImage) === false
    @test Augmentor.supports_stepview(CacheImage) === false
    @test Augmentor.supports_permute(CacheImage) === false
    @test Augmentor.supports_affine(CacheImage) === false
    @test Augmentor.supports_affineview(CacheImage) === false

    @test_throws MethodError Augmentor.applylazy(CacheImage(), v)
    @test_throws MethodError Augmentor.applyview(CacheImage(), v)
    @test_throws MethodError Augmentor.applystepview(CacheImage(), v)
    @test_throws MethodError Augmentor.applypermute(CacheImage(), v)
    @test_throws MethodError Augmentor.applyaffine(CacheImage(), v)
    @test_throws MethodError Augmentor.applyaffineview(CacheImage(), v)
end

# --------------------------------------------------------------------

@testset "CacheImageInto" begin
    @test_throws UndefVarError CacheImageInto
    @test (Augmentor.CacheImageInto <: Augmentor.AffineOperation) == false
    @test (Augmentor.CacheImageInto <: Augmentor.ImageOperation) == true
    @test_throws MethodError Augmentor.CacheImageInto()

    buf = copy(rect)
    @test typeof(@inferred(CacheImage(buf))) <: Augmentor.CacheImageInto
    op = @inferred CacheImage(buf)
    @test Augmentor.CacheImageInto(buf) === op
    @test str_show(op) == "Augmentor.CacheImageInto(::Array{Gray{N0f8},2})"
    @test_broken str_showconst(op) == "CacheImage(Array{Gray{N0f8}}(2, 3))"
    op2 = @inferred CacheImage(Array{Gray{N0f8}}(2, 3))
    @test typeof(op) == typeof(op2)
    @test typeof(op.buffer) == typeof(op2.buffer)
    @test size(op.buffer) == size(op2.buffer)
    @test str_showcompact(op) == "Cache into preallocated 2×3 Array{Gray{N0f8},2}"

    v = Augmentor.applylazy(Resize(2,3), camera)
    res = @inferred Augmentor.applyeager(op, v)
    @test res == v
    @test typeof(res) <: OffsetArray
    @test parent(res) === op.buffer

    res = @inferred Augmentor.applyeager(op, rect)
    @test res == rect
    @test res === op.buffer

    res = @inferred Augmentor.applylazy(op, v)
    @test res == v
    @test typeof(res) <: OffsetArray
    @test parent(res) === op.buffer

    res = @inferred Augmentor.applylazy(op, rect)
    @test res == rect
    @test res === op.buffer

    @test_throws BoundsError Augmentor.applyeager(op, camera)

    @test Augmentor.supports_eager(Augmentor.CacheImageInto) === true
    @test Augmentor.supports_lazy(Augmentor.CacheImageInto) === true
    @test Augmentor.supports_view(Augmentor.CacheImageInto) === false
    @test Augmentor.supports_stepview(Augmentor.CacheImageInto) === false
    @test Augmentor.supports_permute(Augmentor.CacheImageInto) === false
    @test Augmentor.supports_affine(Augmentor.CacheImageInto) === false
    @test Augmentor.supports_affineview(Augmentor.CacheImageInto) === false

    @test_throws MethodError Augmentor.applyview(CacheImage(buf), v)
    @test_throws MethodError Augmentor.applystepview(CacheImage(buf), v)
    @test_throws MethodError Augmentor.applypermute(CacheImage(buf), v)
    @test_throws MethodError Augmentor.applyaffine(CacheImage(buf), v)
    @test_throws MethodError Augmentor.applyaffineview(CacheImage(buf), v)
end
