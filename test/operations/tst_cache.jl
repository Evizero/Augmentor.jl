@testset "CacheImage" begin
    @test (CacheImage <: Augmentor.AffineOperation) == false
    @test (CacheImage <: Augmentor.ImageOperation) == true
    @test typeof(@inferred(CacheImage())) <: CacheImage
    @test str_show(CacheImage()) == "Augmentor.CacheImage()"
    @test str_showconst(CacheImage()) == "CacheImage()"
    @test str_showcompact(CacheImage()) == "Cache into temporary buffer"

    @test @inferred(Augmentor.applyeager(CacheImage(),square)) === square
    @test @inferred(Augmentor.applyeager(CacheImage(),(square,))) === (square,)
    @test @inferred(Augmentor.applyeager(CacheImage(),(square,square2))) === (square,square2)

    # SubArray
    v = view(square, :, :)
    img = @inferred Augmentor.applyeager(CacheImage(), v)
    @test typeof(img) <: Array
    @test eltype(img) == eltype(v)
    @test img !== square
    @test img == square
    # Identidy ranges
    v = view(square, IdentityRange(1:3), IdentityRange(1:3))
    img = @inferred Augmentor.applyeager(CacheImage(), v)
    @test typeof(img) <: OffsetArray
    @test eltype(img) == eltype(v)
    @test img == OffsetArray(square, 0, 0)
    # Affine
    v = Augmentor.prepareaffine(square)
    img = @inferred Augmentor.applyeager(CacheImage(), v)
    @test typeof(img) <: OffsetArray
    @test eltype(img) == eltype(v)
    @test img == OffsetArray(square, 0, 0)
    # Array and SubArray
    v = view(square, :, :)
    tmp,img = @inferred Augmentor.applyeager(CacheImage(), (square,v))
    @test typeof(img) <: Array
    @test eltype(img) == eltype(v)
    @test tmp === square
    @test img !== square
    @test img == square
    # OffsetArray
    o = OffsetArray(square, (-1,2))
    @test @inferred(Augmentor.applyeager(CacheImage(),o)) === o
    @test @inferred(Augmentor.applyeager(CacheImage(),(o,square))) === (o,square)

    @test Augmentor.supports_eager(CacheImage) === true
    @test Augmentor.supports_lazy(CacheImage) === false
    @test Augmentor.supports_view(CacheImage) === false
    @test Augmentor.supports_stepview(CacheImage) === false
    @test Augmentor.supports_permute(CacheImage) === false
    @test Augmentor.supports_affine(CacheImage) === false
    @test Augmentor.supports_affineview(CacheImage) === false

    @test_throws MethodError Augmentor.applylazy(CacheImage(), v)
    @test_throws MethodError Augmentor.applylazy(CacheImage(), (v,v))
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

    @testset "single image" begin
        buf = copy(rect)
        @test typeof(@inferred(CacheImage(buf))) <: Augmentor.CacheImageInto
        op = @inferred CacheImage(buf)
        @test Augmentor.CacheImageInto(buf) === op
        @test str_show(op) == "Augmentor.CacheImageInto(::Array{Gray{N0f8},2})"
        @test str_showconst(op) == "CacheImage(Array{Gray{N0f8}}(2, 3))"
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
        @test_throws MethodError Augmentor.applyview(CacheImage(buf), v)
        @test_throws MethodError Augmentor.applystepview(CacheImage(buf), v)
        @test_throws MethodError Augmentor.applypermute(CacheImage(buf), v)
        @test_throws MethodError Augmentor.applyaffine(CacheImage(buf), v)
        @test_throws MethodError Augmentor.applyaffineview(CacheImage(buf), v)
    end

    @testset "multiple images" begin
        buf1 = copy(square)
        buf2 = copy(rgb_rect)
        @test typeof(@inferred(CacheImage(buf1,buf2))) <: Augmentor.CacheImageInto
        op = @inferred CacheImage(buf1,buf2)
        @test op === @inferred CacheImage((buf1,buf2))
        @test Augmentor.CacheImageInto((buf1,buf2)) === op
        @test str_show(op) == "Augmentor.CacheImageInto((::Array{Gray{N0f8},2}, ::Array{RGB{N0f8},2}))"
        @test str_showconst(op) == "CacheImage(Array{Gray{N0f8}}(3, 3), Array{RGB{N0f8}}(2, 3))"
        op2 = @inferred CacheImage(Array{Gray{N0f8}}(3, 3), Array{RGB{N0f8}}(2, 3))
        @test typeof(op) == typeof(op2)
        @test typeof(op.buffer) == typeof(op2.buffer)
        @test size.(op.buffer) === size.(op2.buffer)
        @test str_showcompact(op) == "Cache into preallocated (3×3 Array{Gray{N0f8},2}, 2×3 Array{RGB{N0f8},2})"

        @test buf1 == square
        @test buf2 == rgb_rect
        v1 = Augmentor.applylazy(Resize(3,3), camera)
        v2 = Augmentor.applylazy(Resize(2,3), RGB.(camera))
        res = @inferred Augmentor.applyeager(op, (v1,v2))
        @test buf1 != square
        @test buf2 != rgb_rect
        @test res == (v1, v2)
        @test typeof(res) <: NTuple{2,OffsetArray}
        @test parent.(res) === (op.buffer[1], op.buffer[2])

        @test_throws BoundsError Augmentor.applyeager(op, (camera,buf1))
        @test_throws MethodError Augmentor.applylazy(op, v1)
        @test_throws BoundsError Augmentor.applylazy(op, (buf2,buf1))
        @test_throws BoundsError Augmentor.applylazy(op, (buf1,))
        # ?
        @test_throws DimensionMismatch Augmentor.applylazy(op, (v1,v1))
    end

    @test Augmentor.supports_eager(Augmentor.CacheImageInto) === true
    @test Augmentor.supports_lazy(Augmentor.CacheImageInto) === true
    @test Augmentor.supports_view(Augmentor.CacheImageInto) === false
    @test Augmentor.supports_stepview(Augmentor.CacheImageInto) === false
    @test Augmentor.supports_permute(Augmentor.CacheImageInto) === false
    @test Augmentor.supports_affine(Augmentor.CacheImageInto) === false
    @test Augmentor.supports_affineview(Augmentor.CacheImageInto) === false
end
