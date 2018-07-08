@testset "ElasticDistortion" begin
    @test (ElasticDistortion <: Augmentor.AffineOperation) == false
    @test (ElasticDistortion <: Augmentor.ImageOperation) == true

    @testset "constructor" begin
        @test_throws MethodError ElasticDistortion()
        let op = @inferred ElasticDistortion(3)
            @test op.gridheight == 3
            @test op.gridwidth == 3
            @test str_show(op) == "Augmentor.ElasticDistortion(3, 3)"
            @test str_showconst(op) == "ElasticDistortion(3, 3)"
            @test str_showcompact(op) == "Distort using a smoothed and normalized 3×3 grid with pinned border"
        end
        let op = @inferred ElasticDistortion(3, 4)
            @test op.gridheight == 3
            @test op.gridwidth == 4
            @test str_show(op) == "Augmentor.ElasticDistortion(3, 4)"
            @test str_showconst(op) == "ElasticDistortion(3, 4)"
            @test str_showcompact(op) == "Distort using a smoothed and normalized 3×4 grid with pinned border"
        end
        let op = @inferred ElasticDistortion(3, 4, 0.6)
            @test op.gridheight == 3
            @test op.gridwidth == 4
            @test op.scale == 0.6
            @test str_show(op) == "Augmentor.ElasticDistortion(3, 4, scale=0.6)"
            @test str_showconst(op) == "ElasticDistortion(3, 4, scale=0.6)"
            @test str_showcompact(op) == "Distort using a smoothed and normalized 3×4 grid with pinned border"
        end
        let op = @inferred ElasticDistortion(3, 4, 0.6, 0.2)
            @test op.gridheight == 3
            @test op.gridwidth == 4
            @test op.scale == 0.6
            @test op.sigma == 0.2
            @test str_show(op) == "Augmentor.ElasticDistortion(3, 4, scale=0.6, sigma=0.2)"
            @test str_showconst(op) == "ElasticDistortion(3, 4, scale=0.6, sigma=0.2)"
            @test str_showcompact(op) == "Distort using a smoothed and normalized 3×4 grid with pinned border"
        end
        let op = @inferred ElasticDistortion(3, 4, 0.6, 0.2, 2, false, true)
            @test op.gridheight == 3
            @test op.gridwidth == 4
            @test op.scale == 0.6
            @test op.sigma == 0.2
            @test op.iterations == 2
            @test op.border == false
            @test op.normalize == true
            @test str_show(op) == "Augmentor.ElasticDistortion(3, 4, scale=0.6, sigma=0.2, iter=2)"
            @test str_showconst(op) == "ElasticDistortion(3, 4, scale=0.6, sigma=0.2, iter=2)"
            @test str_showcompact(op) == "Distort using a 2-times smoothed and normalized 3×4 grid with pinned border"
        end
        let op = @inferred ElasticDistortion(3, 4, 0.6, 0.2, 1, true, false)
            @test op.gridheight == 3
            @test op.gridwidth == 4
            @test op.scale == 0.6
            @test op.sigma == 0.2
            @test op.iterations == 1
            @test op.border == true
            @test op.normalize == false
            @test str_show(op) == "Augmentor.ElasticDistortion(3, 4, scale=0.6, sigma=0.2, border=true, norm=false)"
            @test str_showconst(op) == "ElasticDistortion(3, 4, scale=0.6, sigma=0.2, border=true, norm=false)"
            @test str_showcompact(op) == "Distort using a smoothed 3×4 grid"
        end
        let op = ElasticDistortion(3, 4, 0.6, sigma=0.2, iter=2, norm=false, border=false)
            @test op.gridheight == 3
            @test op.gridwidth == 4
            @test op.scale == 0.6
            @test op.sigma == 0.2
            @test op.iterations == 2
            @test op.border == false
            @test op.normalize == false
            @test str_show(op) == "Augmentor.ElasticDistortion(3, 4, scale=0.6, sigma=0.2, iter=2, norm=false)"
            @test str_showconst(op) == "ElasticDistortion(3, 4, scale=0.6, sigma=0.2, iter=2, norm=false)"
            @test str_showcompact(op) == "Distort using a 2-times smoothed 3×4 grid with pinned border"
        end
        let op = ElasticDistortion(3, 4, scale=0.6, sigma=0.2, iter=2, norm=false, border=false)
            @test op.gridheight == 3
            @test op.gridwidth == 4
            @test op.scale == 0.6
            @test op.sigma == 0.2
            @test op.iterations == 2
            @test op.border == false
            @test op.normalize == false
            @test str_show(op) == "Augmentor.ElasticDistortion(3, 4, scale=0.6, sigma=0.2, iter=2, norm=false)"
            @test str_showconst(op) == "ElasticDistortion(3, 4, scale=0.6, sigma=0.2, iter=2, norm=false)"
            @test str_showcompact(op) == "Distort using a 2-times smoothed 3×4 grid with pinned border"
        end
    end
    imgs = [
        (rect),
        (Augmentor.prepareaffine(rect)),
        (OffsetArray(rect, -2, -1)),
        (view(rect, IdentityRange(1:2), IdentityRange(1:3))),
    ]
    @testset "eager" begin
        @test Augmentor.supports_eager(ElasticDistortion) === false
        # TODO: better tests
        @testset "single image" begin
            for img_in in imgs
                res = @inferred(Augmentor.applyeager(ElasticDistortion(4,4), img_in))
                @test size(res) == size(rect)
                @test typeof(res) <: Array{eltype(img_in),2}
            end
        end
        @testset "multiple images" begin
            for img_in1 in imgs, img_in2 in imgs
                img_in = (img_in1, img_in2)
                res = @inferred(Augmentor.applyeager(ElasticDistortion(4,4), img_in))
                @test res[1] == res[2]
                @test typeof(res) <: NTuple{2,Array{eltype(img_in1),2}}
            end
        end
    end
    @testset "affine" begin
        @test Augmentor.supports_affine(ElasticDistortion) === false
    end
    @testset "affineview" begin
        @test Augmentor.supports_affineview(ElasticDistortion) === false
    end
    @testset "lazy" begin
        @test Augmentor.supports_lazy(ElasticDistortion) === true
        @testset "single image" begin
            for img in imgs
                res = @inferred(Augmentor.applylazy(ElasticDistortion(4,4), img))
                @test size(res) == size(rect)
                @test typeof(res) <: Augmentor.DistortedView{eltype(rect)}
                @test parent(res) === img
            end
        end
        @testset "multiple images" begin
            for img_in1 in imgs, img_in2 in imgs
                img_in = (img_in1, img_in2)
                res = @inferred(Augmentor.applylazy(ElasticDistortion(4,4), img_in))
                @test res[1] == res[2]
                @test res[1].field.itp.coefs === res[2].field.itp.coefs
                @test typeof(res) <: NTuple{2,Augmentor.DistortedView{eltype(img_in1)}}
            end
        end
    end
    @testset "view" begin
        @test Augmentor.supports_view(ElasticDistortion) === false
    end
    @testset "stepview" begin
        @test Augmentor.supports_stepview(ElasticDistortion) === false
    end
    @testset "permute" begin
        @test Augmentor.supports_permute(ElasticDistortion) === false
    end
end
