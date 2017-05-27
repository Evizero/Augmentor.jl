@testset "Crop" begin
    @test (Crop <: Augmentor.AffineOperation) == false
    @testset "constructor" begin
        @test_throws MethodError Crop()
        @test_throws MethodError Crop(())
        @test typeof(@inferred(Crop(1:10))) <: Crop{1} <: Crop <: Augmentor.Operation
        @test typeof(@inferred(Crop(1:10,3:5))) <: Crop{2} <: Crop <: Augmentor.Operation
        @test @inferred(Crop(1,4,10,5)) === @inferred(Crop((4:8,1:10)))
        @test str_show(Crop(3:4)) == "Augmentor.Crop{1}((3:4,))"
        @test str_showconst(Crop(3:4)) == "Crop(3:4)"
        @test str_showcompact(Crop(3:4)) == "Crop region (3:4,)"
        @test str_show(Crop(1:2,2:3)) == "Augmentor.Crop{2}((1:2,$(SPACE)2:3))"
        @test str_showconst(Crop(1:2,2:3)) == "Crop(1:2, 2:3)"
        @test str_showcompact(Crop(1:2,2:3)) == "Crop region 1:2×2:3"
        @test str_show(Crop(1:2,2:3,3:4)) == "Augmentor.Crop{3}((1:2,$(SPACE)2:3,$(SPACE)3:4))"
        @test str_showconst(Crop(1:2,2:3,3:4)) == "Crop(1:2, 2:3, 3:4)"
        @test str_showcompact(Crop(1:2,2:3,3:4)) == "Crop region (1:2,$(SPACE)2:3,$(SPACE)3:4)"
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(Crop(1:10), nothing)
        @test_throws MethodError Augmentor.applyeager(Crop(1:2,2:3), nothing)
        @test @inferred(Augmentor.supports_eager(Crop)) === false
        for img in (Augmentor.prepareaffine(rect), rect, OffsetArray(rect, -2, -1), view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applyeager(Crop(1:2,2:3), img)) == rect[1:2, 2:3]
            @test typeof(Augmentor.applyeager(Crop(1:2,2:3), img)) <: Array
        end
    end
    @testset "affine" begin
        @test @inferred(Augmentor.isaffine(Crop)) === false
        @test @inferred(Augmentor.supports_affine(Crop)) === true
        @test_throws MethodError Augmentor.applyaffine(Crop(1:2,2:3), nothing)
        @test @inferred(Augmentor.applyaffine(Crop(1:2,2:3), rect)) === view(rect, IdentityRange(1:2), IdentityRange(2:3))
    end
    @testset "lazy" begin
        @test @inferred(Augmentor.supports_lazy(Crop)) === true
        @test @inferred(Augmentor.applylazy(Crop(1:2,2:3), rect)) === view(rect, IdentityRange(1:2), IdentityRange(2:3))
    end
    @testset "view" begin
        @test @inferred(Augmentor.supports_view(Crop)) === true
        @test @inferred(Augmentor.applyview(Crop(1:2,2:3), rect)) === view(rect, IdentityRange(1:2), IdentityRange(2:3))
    end
    @testset "stepview" begin
        @test @inferred(Augmentor.supports_stepview(Crop)) === true
        @test @inferred(Augmentor.applystepview(Crop(1:2,2:3), rect)) === view(rect, 1:1:2, 2:1:3)
    end
    @testset "permute" begin
        @test @inferred(Augmentor.supports_permute(Crop)) === false
    end
end

# --------------------------------------------------------------------

@testset "CropNative" begin
    @test (CropNative <: Augmentor.AffineOperation) == false
    @testset "constructor" begin
        @test_throws MethodError CropNative()
        @test_throws MethodError CropNative(())
        @test typeof(@inferred(CropNative(1:10))) <: CropNative{1} <: CropNative <: Augmentor.Operation
        @test typeof(@inferred(CropNative(1:10,3:5))) <: CropNative{2} <: CropNative <: Augmentor.Operation
        @test @inferred(CropNative(1,4,10,5)) === @inferred(CropNative((4:8,1:10)))
        @test str_show(CropNative(3:4)) == "Augmentor.CropNative{1}((3:4,))"
        @test str_showconst(CropNative(3:4)) == "CropNative(3:4)"
        @test str_showcompact(CropNative(3:4)) == "Crop native region (3:4,)"
        @test str_show(CropNative(1:2,2:3)) == "Augmentor.CropNative{2}((1:2,$(SPACE)2:3))"
        @test str_showconst(CropNative(1:2,2:3)) == "CropNative(1:2, 2:3)"
        @test str_showcompact(CropNative(1:2,2:3)) == "Crop native region 1:2×2:3"
        @test str_show(CropNative(1:2,2:3,3:4)) == "Augmentor.CropNative{3}((1:2,$(SPACE)2:3,$(SPACE)3:4))"
        @test str_showconst(CropNative(1:2,2:3,3:4)) == "CropNative(1:2, 2:3, 3:4)"
        @test str_showcompact(CropNative(1:2,2:3,3:4)) == "Crop native region (1:2,$(SPACE)2:3,$(SPACE)3:4)"
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(CropNative(1:10), nothing)
        @test_throws MethodError Augmentor.applyeager(CropNative(1:2,2:3), nothing)
        @test @inferred(Augmentor.supports_eager(CropNative)) === false
        for img in (Augmentor.prepareaffine(rect), rect, view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applyeager(CropNative(1:2,2:3), img)) == rect[1:2, 2:3]
            @test typeof(Augmentor.applyeager(CropNative(1:2,2:3), img)) <: Array
        end
        img = OffsetArray(rect, -2, -1)
        @test @inferred(Augmentor.applyeager(CropNative(-1:0,1:2), img)) == rect[1:2, 2:3]
        @test typeof(Augmentor.applyeager(CropNative(-1:0,1:2), img)) <: Array
    end
    @testset "affine" begin
        @test @inferred(Augmentor.isaffine(CropNative)) === false
        @test @inferred(Augmentor.supports_affine(CropNative)) === true
        @test_throws MethodError Augmentor.applyaffine(CropNative(1:2,2:3), nothing)
        @test @inferred(Augmentor.applyaffine(CropNative(1:2,2:3), rect)) === view(rect, IdentityRange(1:2), IdentityRange(2:3))
    end
    @testset "lazy" begin
        @test @inferred(Augmentor.supports_lazy(CropNative)) === true
        @test @inferred(Augmentor.applylazy(CropNative(1:2,2:3), rect)) === view(rect, IdentityRange(1:2), IdentityRange(2:3))
    end
    @testset "view" begin
        @test @inferred(Augmentor.supports_view(CropNative)) === true
        @test @inferred(Augmentor.applyview(CropNative(1:2,2:3), rect)) === view(rect, IdentityRange(1:2), IdentityRange(2:3))
    end
    @testset "stepview" begin
        @test @inferred(Augmentor.supports_stepview(CropNative)) === true
        @test @inferred(Augmentor.applystepview(CropNative(1:2,2:3), rect)) === view(rect, 1:1:2, 2:1:3)
    end
    @testset "permute" begin
        @test @inferred(Augmentor.supports_permute(CropNative)) === false
    end
end

# --------------------------------------------------------------------

@testset "CropSize" begin
    @test (CropSize <: Augmentor.AffineOperation) == false
    @test typeof(@inferred(CropSize())) <: CropSize <: Augmentor.Operation
    @testset "constructor" begin
        @test_throws MethodError CropSize(())
        @test_throws MethodError CropSize(1.,2.)
        @test_throws MethodError CropSize(:a)
        @test_throws MethodError CropSize([:a])
        @test_throws ArgumentError CropSize(-1)
        @test_throws ArgumentError CropSize(0,2)
        op = @inferred(CropSize(10))
        @test str_show(op) == "Augmentor.CropSize{1}((10,))"
        @test str_showconst(op) == "CropSize(10)"
        @test str_showcompact(op) == "Crop a 10-length window at the center"
        op = @inferred(CropSize(20,30))
        @test op === CropSize(width=30, height=20)
        @test op.size == (20,30)
        @test str_show(op) == "Augmentor.CropSize{2}((20,$(SPACE)30))"
        @test str_showconst(op) == "CropSize(20, 30)"
        @test str_showcompact(op) == "Crop a 20×30 window around the center"
        op = @inferred(CropSize(20,30,40))
        @test op === @inferred(CropSize((20,30,40)))
        @test op === @inferred(CropSize{3}((20,30,40)))
        @test op.size == (20,30,40)
        @test str_show(op) == "Augmentor.CropSize{3}((20,$(SPACE)30,$(SPACE)40))"
        @test str_showconst(op) == "CropSize(20, 30, 40)"
        @test str_showcompact(op) == "Crop a 20×30×40 window around the center"
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(CropSize(10), nothing)
        @test_throws MethodError Augmentor.applyeager(CropSize(2,3), nothing)
        @test @inferred(Augmentor.supports_eager(CropSize)) === false
        for img in (rect, OffsetArray(rect, -2, -1), view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applyeager(CropSize(2,3), img)) == rect
            @test typeof(Augmentor.applyeager(CropSize(2,3), img)) <: Array
        end
        @test @inferred(Augmentor.applyeager(CropSize(2,2), square2)) == square2[2:3,2:3]
        @test @inferred(Augmentor.applyeager(CropSize(4,4), square2)) == square2
    end
    @testset "affine" begin
        @test @inferred(Augmentor.isaffine(CropSize)) === false
        @test @inferred(Augmentor.supports_affine(CropSize)) === true
        @test_throws MethodError Augmentor.applyaffine(CropSize(1:2,2:3), nothing)
        @test @inferred(Augmentor.applyaffine(CropSize(2,3), rect)) === view(rect, IdentityRange(1:2), IdentityRange(1:3))
        @test @inferred(Augmentor.applyaffine(CropSize(2,2), square2)) === view(square2, IdentityRange(2:3), IdentityRange(2:3))
    end
    @testset "lazy" begin
        @test @inferred(Augmentor.supports_lazy(CropSize)) === true
        @test @inferred(Augmentor.applylazy(CropSize(2,3), rect)) === view(rect, IdentityRange(1:2), IdentityRange(1:3))
        @test @inferred(Augmentor.applylazy(CropSize(2,2), square2)) === view(square2, IdentityRange(2:3), IdentityRange(2:3))
    end
    @testset "view" begin
        @test @inferred(Augmentor.supports_view(CropSize)) === true
        @test @inferred(Augmentor.applyview(CropSize(2,3), rect)) === view(rect, IdentityRange(1:2), IdentityRange(1:3))
        @test @inferred(Augmentor.applyview(CropSize(2,2), square2)) === view(square2, IdentityRange(2:3), IdentityRange(2:3))
    end
    @testset "stepview" begin
        @test @inferred(Augmentor.supports_stepview(CropSize)) === true
        @test @inferred(Augmentor.applystepview(CropSize(2,3), rect)) === view(rect, 1:1:2, 1:1:3)
        @test @inferred(Augmentor.applystepview(CropSize(2,2), square2)) === view(square2, 2:1:3, 2:1:3)
    end
    @testset "permute" begin
        @test @inferred(Augmentor.supports_permute(CropSize)) === false
    end
end

# --------------------------------------------------------------------

@testset "CropRatio" begin
    @test (CropRatio <: Augmentor.AffineOperation) == false
    @test typeof(@inferred(CropRatio())) <: CropRatio <: Augmentor.Operation
    @testset "constructor" begin
        @test_throws MethodError CropRatio(())
        @test_throws MethodError CropRatio(1.,2.)
        @test_throws MethodError CropRatio(:a)
        @test_throws MethodError CropRatio([:a])
        @test_throws ArgumentError CropRatio(-1)
        @test_throws ArgumentError CropRatio(0)
        op = @inferred(CropRatio(3/4))
        @test op === CropRatio(ratio=3/4)
        @test str_show(op) == "Augmentor.CropRatio(0.75)"
        @test str_showconst(op) == "CropRatio(0.75)"
        @test str_showcompact(op) == "Crop to 3:4 aspect ratio"
        op = @inferred(CropRatio(1))
        @test op === @inferred(CropRatio())
        @test op === CropRatio(ratio=1)
        @test str_show(op) == "Augmentor.CropRatio(1.0)"
        @test str_showconst(op) == "CropRatio(1.0)"
        @test str_showcompact(op) == "Crop to 1:1 aspect ratio"
        op = @inferred(CropRatio(2.5))
        @test op === CropRatio(ratio=2.5)
        @test str_show(op) == "Augmentor.CropRatio(2.5)"
        @test str_showconst(op) == "CropRatio(2.5)"
        @test str_showcompact(op) == "Crop to 5:2 aspect ratio"
        op = @inferred(CropRatio(sqrt(2)))
        @test str_showcompact(op) == "Crop to 1.41 aspect ratio"
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(CropRatio(10), nothing)
        @test_throws MethodError Augmentor.applyeager(CropRatio(2), nothing)
        @test @inferred(Augmentor.supports_eager(CropRatio)) === false
        for img in (rect, OffsetArray(rect, -2, -1), view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applyeager(CropRatio(3/2), img)) == rect
            @test typeof(Augmentor.applyeager(CropRatio(3/2), img)) <: Array
        end
        @test @inferred(Augmentor.applyeager(CropRatio(1), rect)) == rect[1:2,1:2]
        @test @inferred(Augmentor.applyeager(CropRatio(1), square)) == square
        @test @inferred(Augmentor.applyeager(CropRatio(1), square2)) == square2
    end
    @testset "affine" begin
        @test @inferred(Augmentor.isaffine(CropRatio)) === false
        @test @inferred(Augmentor.supports_affine(CropRatio)) === true
        @test_throws MethodError Augmentor.applyaffine(CropRatio(1), nothing)
        @test @inferred(Augmentor.applyaffine(CropRatio(1), rect)) === view(rect, IdentityRange(1:2), IdentityRange(1:2))
        @test @inferred(Augmentor.applyaffine(CropRatio(2), square2)) === view(square2, IdentityRange(2:3), IdentityRange(1:4))
        @test @inferred(Augmentor.applyaffine(CropRatio(.5), square2)) === view(square2, IdentityRange(1:4), IdentityRange(2:3))
    end
    @testset "lazy" begin
        @test @inferred(Augmentor.supports_lazy(CropRatio)) === true
        @test @inferred(Augmentor.applylazy(CropRatio(1), rect)) === view(rect, IdentityRange(1:2), IdentityRange(1:2))
        @test @inferred(Augmentor.applylazy(CropRatio(2), square2)) === view(square2, IdentityRange(2:3), IdentityRange(1:4))
        @test @inferred(Augmentor.applylazy(CropRatio(.5), square2)) === view(square2, IdentityRange(1:4), IdentityRange(2:3))
    end
    @testset "view" begin
        @test @inferred(Augmentor.supports_view(CropRatio)) === true
        @test @inferred(Augmentor.applyview(CropRatio(1), rect)) === view(rect, IdentityRange(1:2), IdentityRange(1:2))
        @test @inferred(Augmentor.applyview(CropRatio(2), square2)) === view(square2, IdentityRange(2:3), IdentityRange(1:4))
        @test @inferred(Augmentor.applyview(CropRatio(.5), square2)) === view(square2, IdentityRange(1:4), IdentityRange(2:3))
    end
    @testset "stepview" begin
        @test @inferred(Augmentor.supports_stepview(CropRatio)) === true
        @test @inferred(Augmentor.applystepview(CropRatio(1), rect)) === view(rect, 1:1:2, 1:1:2)
        @test @inferred(Augmentor.applystepview(CropRatio(2), square2)) === view(square2, 2:1:3, 1:1:4)
        @test @inferred(Augmentor.applystepview(CropRatio(.5), square2)) === view(square2, 1:1:4, 2:1:3)
    end
    @testset "permute" begin
        @test @inferred(Augmentor.supports_permute(CropRatio)) === false
    end
end
