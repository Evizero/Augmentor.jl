@testset "Crop" begin
    @test (Crop <: Augmentor.AffineOperation) == false
    @testset "constructor" begin
        @test_throws MethodError Crop()
        @test_throws MethodError Crop(())
        @test typeof(@inferred(Crop(1:10))) <: Crop{1} <: Crop <: Augmentor.Operation
        @test typeof(@inferred(Crop(1:10,3:5))) <: Crop{2} <: Crop <: Augmentor.Operation
        @test @inferred(Crop(1,4,10,5)) === @inferred(Crop((4:8,1:10)))
        @test str_show(Crop(3:4)) == "Augmentor.Crop{1}((3:4,))"
        @test str_showcompact(Crop(3:4)) == "Crop region (3:4,)"
        @test str_show(Crop(1:2,2:3)) == "Augmentor.Crop{2}((1:2,$(SPACE)2:3))"
        @test str_showcompact(Crop(1:2,2:3)) == "Crop region 1:2×2:3"
        @test str_show(Crop(1:2,2:3,3:4)) == "Augmentor.Crop{3}((1:2,$(SPACE)2:3,$(SPACE)3:4))"
        @test str_showcompact(Crop(1:2,2:3,3:4)) == "Crop region (1:2,$(SPACE)2:3,$(SPACE)3:4)"
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(Crop(1:10), nothing)
        @test_throws MethodError Augmentor.applyeager(Crop(1:2,2:3), nothing)
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

@testset "CropDirect" begin
    @test (CropDirect <: Augmentor.AffineOperation) == false
    @testset "constructor" begin
        @test_throws MethodError CropDirect()
        @test_throws MethodError CropDirect(())
        @test typeof(@inferred(CropDirect(1:10))) <: CropDirect{1} <: CropDirect <: Augmentor.Operation
        @test typeof(@inferred(CropDirect(1:10,3:5))) <: CropDirect{2} <: CropDirect <: Augmentor.Operation
        @test @inferred(CropDirect(1,4,10,5)) === @inferred(CropDirect((4:8,1:10)))
        @test str_show(CropDirect(3:4)) == "Augmentor.CropDirect{1}((3:4,))"
        @test str_showcompact(CropDirect(3:4)) == "Crop (directly) region (3:4,)"
        @test str_show(CropDirect(1:2,2:3)) == "Augmentor.CropDirect{2}((1:2,$(SPACE)2:3))"
        @test str_showcompact(CropDirect(1:2,2:3)) == "Crop (directly) region 1:2×2:3"
        @test str_show(CropDirect(1:2,2:3,3:4)) == "Augmentor.CropDirect{3}((1:2,$(SPACE)2:3,$(SPACE)3:4))"
        @test str_showcompact(CropDirect(1:2,2:3,3:4)) == "Crop (directly) region (1:2,$(SPACE)2:3,$(SPACE)3:4)"
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(CropDirect(1:10), nothing)
        @test_throws MethodError Augmentor.applyeager(CropDirect(1:2,2:3), nothing)
        for img in (Augmentor.prepareaffine(rect), rect, view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applyeager(CropDirect(1:2,2:3), img)) == rect[1:2, 2:3]
            @test typeof(Augmentor.applyeager(CropDirect(1:2,2:3), img)) <: Array
        end
        img = OffsetArray(rect, -2, -1)
        @test @inferred(Augmentor.applyeager(CropDirect(-1:0,1:2), img)) == rect[1:2, 2:3]
        @test typeof(Augmentor.applyeager(CropDirect(-1:0,1:2), img)) <: Array
    end
    @testset "affine" begin
        @test @inferred(Augmentor.isaffine(CropDirect)) === false
        @test @inferred(Augmentor.supports_affine(CropDirect)) === true
        @test_throws MethodError Augmentor.applyaffine(CropDirect(1:2,2:3), nothing)
        @test @inferred(Augmentor.applyaffine(CropDirect(1:2,2:3), rect)) === view(rect, IdentityRange(1:2), IdentityRange(2:3))
    end
    @testset "lazy" begin
        @test @inferred(Augmentor.supports_lazy(CropDirect)) === true
        @test @inferred(Augmentor.applylazy(CropDirect(1:2,2:3), rect)) === view(rect, IdentityRange(1:2), IdentityRange(2:3))
    end
    @testset "view" begin
        @test @inferred(Augmentor.supports_view(CropDirect)) === true
        @test @inferred(Augmentor.applyview(CropDirect(1:2,2:3), rect)) === view(rect, IdentityRange(1:2), IdentityRange(2:3))
    end
    @testset "stepview" begin
        @test @inferred(Augmentor.supports_stepview(CropDirect)) === true
        @test @inferred(Augmentor.applystepview(CropDirect(1:2,2:3), rect)) === view(rect, 1:1:2, 2:1:3)
    end
    @testset "permute" begin
        @test @inferred(Augmentor.supports_permute(CropDirect)) === false
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
        @test str_showcompact(op) == "Crop a 10-length window at the center"
        op = @inferred(CropSize(20,30))
        @test op === CropSize(width=30, height=20)
        @test op.size == (20,30)
        @test str_show(op) == "Augmentor.CropSize{2}((20,$(SPACE)30))"
        @test str_showcompact(op) == "Crop a 20×30 window around the center"
        op = @inferred(CropSize(20,30,40))
        @test op === @inferred(CropSize((20,30,40)))
        @test op === @inferred(CropSize{3}((20,30,40)))
        @test op.size == (20,30,40)
        @test str_show(op) == "Augmentor.CropSize{3}((20,$(SPACE)30,$(SPACE)40))"
        @test str_showcompact(op) == "Crop a 20×30×40 window around the center"
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(CropSize(10), nothing)
        @test_throws MethodError Augmentor.applyeager(CropSize(2,3), nothing)
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
