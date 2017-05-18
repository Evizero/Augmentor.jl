@testset "ElasticDistortion" begin
    @test (ElasticDistortion <: Augmentor.AffineOperation) == false
    @test (ElasticDistortion <: Augmentor.Operation) == true

    @testset "constructor" begin
        @test_throws MethodError ElasticDistortion()
        @test_throws MethodError ElasticDistortion(5)
        let op = @inferred ElasticDistortion(3, 4)
            @test op.gridheight == 3
            @test op.gridwidth == 4
        end
        let op = @inferred ElasticDistortion(3, 4, 0.6)
            @test op.gridheight == 3
            @test op.gridwidth == 4
            @test op.scale == 0.6
        end
        let op = @inferred ElasticDistortion(3, 4, 0.6, 0.2)
            @test op.gridheight == 3
            @test op.gridwidth == 4
            @test op.scale == 0.6
            @test op.sigma == 0.2
        end
        let op = @inferred ElasticDistortion(3, 4, 0.6, 0.2, 2, false, true)
            @test op.gridheight == 3
            @test op.gridwidth == 4
            @test op.scale == 0.6
            @test op.sigma == 0.2
            @test op.iterations == 2
            @test op.border == false
            @test op.normalize == true
        end
        let op = @inferred ElasticDistortion(3, 4, 0.6, 0.2, 2, true, false)
            @test op.gridheight == 3
            @test op.gridwidth == 4
            @test op.scale == 0.6
            @test op.sigma == 0.2
            @test op.iterations == 2
            @test op.border == true
            @test op.normalize == false
        end
        let op = ElasticDistortion(3, 4, 0.6, sigma=0.2, iterations=2, normalize=false, border=false)
            @test op.gridheight == 3
            @test op.gridwidth == 4
            @test op.scale == 0.6
            @test op.sigma == 0.2
            @test op.iterations == 2
            @test op.border == false
            @test op.normalize == false
        end
        let op = ElasticDistortion(3, 4, scale=0.6, sigma=0.2, iterations=2, normalize=false, border=false)
            @test op.gridheight == 3
            @test op.gridwidth == 4
            @test op.scale == 0.6
            @test op.sigma == 0.2
            @test op.iterations == 2
            @test op.border == false
            @test op.normalize == false
        end
    end
    @testset "eager" begin
        @test @inferred(Augmentor.supports_eager(ElasticDistortion)) === false
        for img in (square, OffsetArray(square, 0, 0), view(square, IdentityRange(1:3), IdentityRange(1:3)))
            dv = @inferred Augmentor.applyeager(ElasticDistortion(4,4), img)
            # TODO: better tests
            @test size(dv) == size(square)
            @test typeof(dv) <: Array
        end
    end
    @testset "affine" begin
        @test @inferred(Augmentor.supports_affine(ElasticDistortion)) === false
    end
    @testset "lazy" begin
        @test @inferred(Augmentor.supports_lazy(ElasticDistortion)) === true
        for img in (square, OffsetArray(square, 0, 0), view(square, IdentityRange(1:3), IdentityRange(1:3)))
            dv = @inferred Augmentor.applylazy(ElasticDistortion(4,4), img)
            # TODO: better tests
            @test size(dv) == size(square)
            @test typeof(dv) <: Augmentor.DistortedView{eltype(square)}
            @test parent(dv) === img
        end
    end
    @testset "view" begin
        @test @inferred(Augmentor.supports_view(ElasticDistortion)) === false
    end
    @testset "stepview" begin
        @test @inferred(Augmentor.supports_stepview(ElasticDistortion)) === false
    end
    @testset "permute" begin
        @test @inferred(Augmentor.supports_permute(ElasticDistortion)) === false
    end
end
