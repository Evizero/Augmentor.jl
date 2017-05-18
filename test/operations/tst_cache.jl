@testset "CacheImage" begin
    @test (CacheImage <: Augmentor.AffineOperation) == false
    @test (CacheImage <: Augmentor.Operation) == true
    @test typeof(@inferred(CacheImage())) <: CacheImage
    @test str_show(CacheImage()) == "Augmentor.CacheImage()"
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

    @test @inferred(Augmentor.supports_eager(CacheImage)) === true
    @test @inferred(Augmentor.supports_lazy(CacheImage)) === false
    @test @inferred(Augmentor.supports_view(CacheImage)) === false
    @test @inferred(Augmentor.supports_stepview(CacheImage)) === false
    @test @inferred(Augmentor.supports_permute(CacheImage)) === false
    @test @inferred(Augmentor.supports_affine(CacheImage)) === false

    @test_throws MethodError Augmentor.applylazy(CacheImage(), v)
    @test_throws MethodError Augmentor.applyview(CacheImage(), v)
    @test_throws MethodError Augmentor.applystepview(CacheImage(), v)
    @test_throws MethodError Augmentor.applypermute(CacheImage(), v)
    @test_throws MethodError Augmentor.applyaffine(CacheImage(), v)
end

# --------------------------------------------------------------------

@testset "CacheImageInto" begin
    @test_throws UndefVarError CacheImageInto
    @test (Augmentor.CacheImageInto <: Augmentor.AffineOperation) == false
    @test (Augmentor.CacheImageInto <: Augmentor.Operation) == true
    @test_throws MethodError Augmentor.CacheImageInto()

    buf = copy(rect)
    @test typeof(@inferred(CacheImage(buf))) <: Augmentor.CacheImageInto
    op = @inferred CacheImage(buf)
    @test Augmentor.CacheImageInto(buf) === op
    @test str_show(op) == "Augmentor.CacheImageInto(::Array{Gray{N0f8},2})"
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

    @test @inferred(Augmentor.supports_eager(Augmentor.CacheImageInto)) === true
    @test @inferred(Augmentor.supports_lazy(Augmentor.CacheImageInto)) === true
    @test @inferred(Augmentor.supports_view(Augmentor.CacheImageInto)) === false
    @test @inferred(Augmentor.supports_stepview(Augmentor.CacheImageInto)) === false
    @test @inferred(Augmentor.supports_permute(Augmentor.CacheImageInto)) === false
    @test @inferred(Augmentor.supports_affine(Augmentor.CacheImageInto)) === false

    @test_throws MethodError Augmentor.applyview(CacheImage(buf), v)
    @test_throws MethodError Augmentor.applystepview(CacheImage(buf), v)
    @test_throws MethodError Augmentor.applypermute(CacheImage(buf), v)
    @test_throws MethodError Augmentor.applyaffine(CacheImage(buf), v)
end
