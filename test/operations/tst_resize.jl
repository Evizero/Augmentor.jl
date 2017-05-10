@testset "Resize" begin
    @test (Resize <: Augmentor.AffineOperation) == false
    @test typeof(@inferred(Resize())) <: Resize <: Augmentor.Operation
    @testset "constructor" begin
        @test_throws MethodError Resize(())
        @test_throws MethodError Resize(1.,2.)
        @test_throws MethodError Resize(:a)
        @test_throws MethodError Resize([:a])
        @test_throws ArgumentError Resize(-1)
        @test_throws ArgumentError Resize(0,2)
        op = @inferred(Resize(10))
        @test str_show(op) == "Augmentor.Resize{1}((10,))"
        @test str_showcompact(op) == "Resize to (10,)"
        op = @inferred(Resize(20,30))
        @test op === Resize(width=30, height=20)
        @test op.size == (20,30)
        @test str_show(op) == "Augmentor.Resize{2}((20,$(SPACE)30))"
        @test str_showcompact(op) == "Resize to 20×30"
        op = @inferred(Resize(20,30,40))
        @test op === @inferred(Resize((20,30,40)))
        @test op === @inferred(Resize{3}((20,30,40)))
        @test op.size == (20,30,40)
        @test str_show(op) == "Augmentor.Resize{3}((20,$(SPACE)30,$(SPACE)40))"
        @test str_showcompact(op) == "Resize to (20,$(SPACE)30,$(SPACE)40)"
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(Resize(10,10), nothing)
        @test @inferred(Augmentor.supports_eager(Resize)) === true
        ref = Gray{N0f8}[0.624 0.686 0.733 0.686 0.612; 0.667 0.055 0.71 0.675 0.596; 0.639 0.043 0.227 0.631 0.604; 0.569 0.031 0.518 0.553 0.529; 0.392 0.145 0.392 0.443 0.369]
        for img in (camera, OffsetArray(camera, -10, 30), view(camera, IdentityRange(1:512), IdentityRange(1:512)))
            @test @inferred(Augmentor.applyeager(Resize(5,5), img)) == ref
            @test typeof(Augmentor.applyeager(Resize(5,5), img)) <: Array
        end
    end
    @testset "affine" begin
        @test @inferred(Augmentor.isaffine(Resize)) === false
        @test @inferred(Augmentor.supports_affine(Resize)) === false
    end
    @testset "lazy" begin
        @test @inferred(Augmentor.supports_lazy(Resize)) === false
    end
    @testset "view" begin
        @test @inferred(Augmentor.supports_view(Resize)) === false
    end
    @testset "stepview" begin
        @test @inferred(Augmentor.supports_stepview(Resize)) === false
    end
    @testset "permute" begin
        @test @inferred(Augmentor.supports_permute(Resize)) === false
    end
end
