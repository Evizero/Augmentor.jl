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
        for img in (rect, OffsetArray(rect, -2, -1), view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applyeager(Crop(1:2,2:3), rect)) == rect[1:2, 2:3]
            @test typeof(Augmentor.applyeager(Crop(1:2,2:3), rect)) <: Array
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
