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
    @test str_show(NoOp()) == "Augmentor.NoOp()"
    @test str_showcompact(NoOp()) == "No operation"

    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(NoOp(), nothing)
        @test @inferred(Augmentor.applyeager(NoOp(), square)) === square
        @test @inferred(Augmentor.applyeager(NoOp(), OffsetArray(square, (-1,-2)))) === square
    end
    @testset "affine" begin
        @test @inferred(Augmentor.isaffine(NoOp)) === true
        @test @inferred(Augmentor.supports_affine(NoOp)) === true
        @test @inferred(Augmentor.toaffine(NoOp(), nothing)) == AffineMap(@SMatrix([1. 0; 0 1]), @SVector([0., 0.]))
        wv = @inferred Augmentor.applyaffine(NoOp(), square)
        @test wv == square
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "lazy" begin
        @test @inferred(Augmentor.supports_lazy(NoOp)) === true
        @test @inferred(Augmentor.applylazy(NoOp(), nothing)) === nothing
        @test @inferred(Augmentor.applylazy(NoOp(), square)) === square
    end
    @testset "view" begin
        @test @inferred(Augmentor.supports_view(NoOp)) === true
        @test @inferred(Augmentor.applyview(NoOp(), square)) === view(square, IdentityRange(1:2), IdentityRange(1:3))
    end
    @testset "stepview" begin
        @test @inferred(Augmentor.supports_stepview(NoOp)) === true
        @test @inferred(Augmentor.applystepview(NoOp(), square)) === view(square, 1:1:2, 1:1:3)
    end
    @testset "permute" begin
        @test @inferred(Augmentor.supports_permute(NoOp)) === false
    end
end

# --------------------------------------------------------------------

@testset "Rotate90" begin
    @test typeof(@inferred(Rotate90())) <: Rotate90 <: Augmentor.AffineOperation
    @test str_show(Rotate90()) == "Augmentor.Rotate90()"
    @test str_showcompact(Rotate90()) == "Rotate 90 degree"

    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(Rotate90(), nothing)
        for img in (square, OffsetArray(square, -2, -1))
            @test @inferred(Augmentor.applyeager(Rotate90(), img)) == rotl90(square)
            @test typeof(Augmentor.applyeager(Rotate90(), img)) <: Array
        end
    end
    @testset "affine" begin
        @test @inferred(Augmentor.isaffine(Rotate90)) === true
        @test @inferred(Augmentor.supports_affine(Rotate90)) === true
        @test_throws MethodError Augmentor.applyaffine(Rotate90(), nothing)
        @test @inferred(Augmentor.toaffine(Rotate90(), square)) ≈ AffineMap([6.12323e-17 -1.0; 1.0 6.12323e-17], [3.5,0.5])
        wv = @inferred Augmentor.applyaffine(Rotate90(), square)
        # TODO: test lazy result
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "lazy" begin
        @test @inferred(Augmentor.supports_lazy(Rotate90)) === true
        v = @inferred Augmentor.applylazy(Rotate90(), square)
        @test v === view(permuteddimsview(square, (2,1)), 3:-1:1, 1:1:2)
        @test v == rotl90(square)
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
        v = @inferred Augmentor.applypermute(Rotate90(), square)
        @test v === view(permuteddimsview(square, (2,1)), 3:-1:1, 1:1:2)
        @test v == rotl90(square)
        @test typeof(v) <: SubArray
    end
end

# --------------------------------------------------------------------

@testset "Rotate180" begin
    @test typeof(@inferred(Rotate180())) <: Rotate180 <: Augmentor.AffineOperation
    @test str_show(Rotate180()) == "Augmentor.Rotate180()"
    @test str_showcompact(Rotate180()) == "Rotate 180 degree"

    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(Rotate180(), nothing)
        for img in (square, OffsetArray(square, -2, -1))
            @test @inferred(Augmentor.applyeager(Rotate180(), img)) == rot180(square)
            @test typeof(Augmentor.applyeager(Rotate180(), img)) <: Array
        end
    end
    @testset "affine" begin
        @test @inferred(Augmentor.isaffine(Rotate180)) === true
        @test @inferred(Augmentor.supports_affine(Rotate180)) === true
        @test_throws MethodError Augmentor.applyaffine(Rotate180(), nothing)
        @test @inferred(Augmentor.toaffine(Rotate180(), square)) ≈ AffineMap([-1.0 -1.22465e-16; 1.22465e-16 -1.0], [3.0,4.0])
        wv = @inferred Augmentor.applyaffine(Rotate180(), square)
        # TODO: test lazy result
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "lazy" begin
        @test @inferred(Augmentor.supports_lazy(Rotate180)) === true
        v = @inferred Augmentor.applylazy(Rotate180(), square)
        @test v === view(square, 2:-1:1, 3:-1:1)
        @test v == rot180(square)
        @test typeof(v) <: SubArray
    end
    @testset "view" begin
        @test @inferred(Augmentor.supports_view(Rotate180)) === false
    end
    @testset "stepview" begin
        @test @inferred(Augmentor.supports_stepview(Rotate180)) === true
        v = @inferred Augmentor.applylazy(Rotate180(), square)
        @test v === view(square, 2:-1:1, 3:-1:1)
        @test v == rot180(square)
        @test typeof(v) <: SubArray
    end
    @testset "permute" begin
        @test @inferred(Augmentor.supports_permute(Rotate180)) === false
    end
end

# --------------------------------------------------------------------

@testset "Rotate270" begin
    @test typeof(@inferred(Rotate270())) <: Rotate270 <: Augmentor.AffineOperation
    @test str_show(Rotate270()) == "Augmentor.Rotate270()"
    @test str_showcompact(Rotate270()) == "Rotate 270 degree"

    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(Rotate270(), nothing)
        for img in (square, OffsetArray(square, -2, -1))
            @test @inferred(Augmentor.applyeager(Rotate270(), img)) == rotr90(square)
            @test typeof(Augmentor.applyeager(Rotate270(), img)) <: Array
        end
    end
    @testset "affine" begin
        @test @inferred(Augmentor.isaffine(Rotate270)) === true
        @test @inferred(Augmentor.supports_affine(Rotate270)) === true
        @test_throws MethodError Augmentor.applyaffine(Rotate270(), nothing)
        @test @inferred(Augmentor.toaffine(Rotate270(), square)) ≈ AffineMap([6.12323e-17 1.0; -1.0 6.12323e-17], [-0.5,3.5])
        wv = @inferred Augmentor.applyaffine(Rotate270(), square)
        # TODO: test lazy result
        @test typeof(wv) <: InvWarpedView{eltype(square),2}
    end
    @testset "lazy" begin
        @test @inferred(Augmentor.supports_lazy(Rotate270)) === true
        v = @inferred Augmentor.applylazy(Rotate270(), square)
        @test v === view(permuteddimsview(square, (2,1)), 1:1:3, 2:-1:1)
        @test v == rotr90(square)
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
        v = @inferred Augmentor.applypermute(Rotate270(), square)
        @test v === view(permuteddimsview(square, (2,1)), 1:1:3, 2:-1:1)
        @test v == rotr90(square)
        @test typeof(v) <: SubArray
    end
end

# --------------------------------------------------------------------

@testset "Crop" begin
    @test (Crop <: Augmentor.AffineOperation) == false
    @test_throws MethodError Crop()
    @test_throws MethodError Crop(())
    @test typeof(@inferred(Crop(1:10))) <: Crop{1} <: Crop <: Augmentor.Operation
    @test typeof(@inferred(Crop(1:10,3:5))) <: Crop{2} <: Crop <: Augmentor.Operation
    @test @inferred(Crop(1,4,10,5)) === @inferred(Crop((4:8,1:10)))
    @test str_show(Crop(3:4)) == "Augmentor.Crop{1}((3:4,))"
    @test str_show(Crop(1:2,2:3)) == "Augmentor.Crop{2}((1:2,$(SPACE)2:3))"
    @test str_showcompact(Crop(1:2,2:3)) == "Crop region (1:2,$(SPACE)2:3)"

    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(Crop(1:10), nothing)
        @test_throws MethodError Augmentor.applyeager(Crop(1:2,2:3), nothing)
        for img in (square, OffsetArray(square, -2, -1))
            @test @inferred(Augmentor.applyeager(Crop(1:2,2:3), square)) == square[1:2, 2:3]
            @test typeof(Augmentor.applyeager(Crop(1:2,2:3), square)) <: Array
        end
    end
    @testset "affine" begin
        @test @inferred(Augmentor.isaffine(Crop)) === false
        @test @inferred(Augmentor.supports_affine(Crop)) === true
        @test_throws MethodError Augmentor.applyaffine(Crop(1:2,2:3), nothing)
        @test @inferred(Augmentor.applyaffine(Crop(1:2,2:3), square)) === view(square, IdentityRange(1:2), IdentityRange(2:3))
    end
    @testset "lazy" begin
        @test @inferred(Augmentor.supports_lazy(Crop)) === true
        @test @inferred(Augmentor.applylazy(Crop(1:2,2:3), square)) === view(square, IdentityRange(1:2), IdentityRange(2:3))
    end
    @testset "view" begin
        @test @inferred(Augmentor.supports_view(Crop)) === true
        @test @inferred(Augmentor.applyview(Crop(1:2,2:3), square)) === view(square, IdentityRange(1:2), IdentityRange(2:3))
    end
    @testset "stepview" begin
        @test @inferred(Augmentor.supports_stepview(Crop)) === true
        @test @inferred(Augmentor.applystepview(Crop(1:2,2:3), square)) === view(square, 1:1:2, 2:1:3)
    end
    @testset "permute" begin
        @test @inferred(Augmentor.supports_permute(Crop)) === false
    end
end

# --------------------------------------------------------------------

@testset "Either" begin
    @test (Either <: Augmentor.AffineOperation) == false
    @test str_show(Either((Rotate90(),Rotate270(),NoOp()), (0.2,0.3,0.5))) == """
    Augmentor.Either (1 out of 3 operation(s)):
      - 20.0% chance to: Rotate 90 degree
      - 30.0% chance to: Rotate 270 degree
      - 50.0% chance to: No operation"""
    @test str_showcompact(Either((Rotate90(),Rotate270(),NoOp()), (0.2,0.3,0.5))) ==
        "Either: (20%) Rotate 90 degree. (30%) Rotate 270 degree. (50%) No operation."
end
