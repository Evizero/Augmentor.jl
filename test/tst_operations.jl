function str_show(obj)
    io = IOBuffer()
    Base.show(io, obj)
    readstring(seek(io, 0))
end

function str_showcompact(obj)
    io = IOBuffer()
    Base.showcompact(io, obj)
    readstring(seek(io, 0))
end

SPACE = VERSION < v"0.6.0-dev.2505" ? "" : " " # julia PR #20288

square = Gray{N0f8}[0.1 0.2 0.3; 0.4 0.5 0.6]

@test Augmentor.AffineOperation <: Augmentor.Operation

# --------------------------------------------------------------------

@testset "NoOp" begin
    @test typeof(@inferred(NoOp())) <: NoOp <: Augmentor.AffineOperation
    @test @inferred(Augmentor.islazy(NoOp)) === true
    @test @inferred(Augmentor.isaffine(NoOp)) === true

    @test @inferred(toaffine(NoOp(), nothing)) == AffineMap(@SMatrix([1. 0; 0 1]), @SVector([0., 0.]))
    @test_throws MethodError Augmentor.applyeager(NoOp(), nothing)
    @test @inferred(Augmentor.applyeager(NoOp(), square)) === square
    @test @inferred(Augmentor.applyeager(NoOp(), OffsetArray(square, (-1,-2)))) === square

    @test_throws MethodError Augmentor.applylazy(NoOp(), nothing)
    wv = @inferred Augmentor.applylazy(NoOp(), square)
    @test wv == square
    @test typeof(wv) <: InvWarpedView{eltype(square),2}

    @test str_show(NoOp()) == "Augmentor.NoOp()"
    @test str_showcompact(NoOp()) == "No operation"
end

# --------------------------------------------------------------------

@testset "Rotate90" begin
    @test typeof(@inferred(Rotate90())) <: Rotate90 <: Augmentor.AffineOperation
    @test @inferred(Augmentor.islazy(Rotate90)) === true
    @test @inferred(Augmentor.isaffine(Rotate90)) === true

    @test @inferred(toaffine(Rotate90(), square)) ≈ AffineMap([6.12323e-17 -1.0; 1.0 6.12323e-17], [3.5,0.5])
    @test_throws MethodError Augmentor.applyeager(Rotate90(), nothing)
    @test @inferred(Augmentor.applyeager(Rotate90(), square)) == rotl90(square)

    @test_throws MethodError Augmentor.applylazy(Rotate90(), nothing)
    wv = @inferred Augmentor.applylazy(Rotate90(), square)
    # TODO: test lazy result
    @test typeof(wv) <: InvWarpedView{eltype(square),2}

    @test str_show(Rotate90()) == "Augmentor.Rotate90()"
    @test str_showcompact(Rotate90()) == "Rotate 90 degree"
end

# --------------------------------------------------------------------

@testset "Rotate180" begin
    @test typeof(@inferred(Rotate180())) <: Rotate180 <: Augmentor.AffineOperation
    @test @inferred(Augmentor.islazy(Rotate180)) === true
    @test @inferred(Augmentor.isaffine(Rotate180)) === true

    @test @inferred(toaffine(Rotate180(), square)) ≈ AffineMap([-1.0 -1.22465e-16; 1.22465e-16 -1.0], [3.0,4.0])
    @test_throws MethodError Augmentor.applyeager(Rotate180(), nothing)
    @test @inferred(Augmentor.applyeager(Rotate180(), square)) == rot180(square)

    @test_throws MethodError Augmentor.applylazy(Rotate180(), nothing)
    wv = @inferred Augmentor.applylazy(Rotate180(), square)
    # TODO: test lazy result
    @test typeof(wv) <: InvWarpedView{eltype(square),2}

    @test str_show(Rotate180()) == "Augmentor.Rotate180()"
    @test str_showcompact(Rotate180()) == "Rotate 180 degree"
end

# --------------------------------------------------------------------

@testset "Rotate270" begin
    @test typeof(@inferred(Rotate270())) <: Rotate270 <: Augmentor.AffineOperation
    @test @inferred(Augmentor.islazy(Rotate270)) === true
    @test @inferred(Augmentor.isaffine(Rotate270)) === true

    @test @inferred(toaffine(Rotate270(), square)) ≈ AffineMap([6.12323e-17 1.0; -1.0 6.12323e-17], [-0.5,3.5])
    @test_throws MethodError Augmentor.applyeager(Rotate270(), nothing)
    @test @inferred(Augmentor.applyeager(Rotate270(), square)) == rotr90(square)

    @test_throws MethodError Augmentor.applylazy(Rotate270(), nothing)
    wv = @inferred Augmentor.applylazy(Rotate270(), square)
    # TODO: test lazy result
    @test typeof(wv) <: InvWarpedView{eltype(square),2}

    @test str_show(Rotate270()) == "Augmentor.Rotate270()"
    @test str_showcompact(Rotate270()) == "Rotate 270 degree"
end

# --------------------------------------------------------------------

@testset "Crop" begin
    @test (Crop <: Augmentor.AffineOperation) == false
    @test_throws MethodError Crop()
    @test_throws MethodError Crop(())
    @test typeof(@inferred(Crop(1:10))) <: Crop{1} <: Crop <: Augmentor.Operation
    @test typeof(@inferred(Crop(1:10,3:5))) <: Crop{2} <: Crop <: Augmentor.Operation
    @test @inferred(Crop(1,4,10,5)) === @inferred(Crop((4:8,1:10)))
    @test @inferred(Augmentor.islazy(Crop)) === true
    @test @inferred(Augmentor.isaffine(Crop)) === false

    @test_throws MethodError Augmentor.applyeager(Crop(1:10), nothing)
    @test @inferred(Augmentor.applyeager(Crop(1:2,2:3), square)) == square[1:2, 2:3]
    @test typeof(Augmentor.applyeager(Crop(1:2,2:3), square)) <: Array

    @test_throws MethodError Augmentor.applylazy(Crop(1:10), nothing)
    wv = @inferred Augmentor.applylazy(Crop(1:2,2:3), square)
    @test wv === view(square, IdentityRange(1:2), IdentityRange(2:3))
    @test typeof(wv) <: SubArray{eltype(square),2}

    @test str_show(Crop(3:4)) == "Augmentor.Crop{1}((3:4,))"
    @test str_show(Crop(1:2,2:3)) == "Augmentor.Crop{2}((1:2,$(SPACE)2:3))"
    @test str_showcompact(Crop(1:2,2:3)) == "Crop region (1:2,$(SPACE)2:3)"
end
