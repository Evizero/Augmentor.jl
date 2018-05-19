@testset "MapFun" begin
    @test (MapFun <: Augmentor.ImageOperation) == false
    @test (MapFun <: Augmentor.Operation) == true
    @testset "constructor" begin
        @test_throws MethodError MapFun()
        @test typeof(@inferred(MapFun((x)->x))) <: MapFun <: Augmentor.Operation
        @test typeof(@inferred(MapFun(identity))) <: MapFun <: Augmentor.Operation
        @test str_show(MapFun(identity)) == "Augmentor.MapFun(identity)"
        @test str_showconst(MapFun(identity)) == "MapFun(identity)"
        @test str_showcompact(MapFun(identity)) == "Map function \"identity\" over image"
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(MapFun(identity), nothing)
        @test Augmentor.supports_eager(MapFun) === true
        res1 = map(x->x-Gray{Float32}(0.1), rect)
        res2 = map(x->x-Gray{Float32}(0.1), OffsetArray(rect,0,0))
        imgs = [
            (rect, res1),
            (view(rect,:,:), res1),
            (Augmentor.prepareaffine(rect), res2),
            (OffsetArray(rect, 0, 0), res2),
            (view(rect, IdentityRange(1:2), IdentityRange(1:3)), res2),
        ]
        @testset "single image" begin
            for (img_in, img_out) in imgs
                res = @inferred(Augmentor.applyeager(MapFun(identity), img_in))
                @test res == img_in
                @test eltype(res) <: Gray{N0f8}
                @test typeof(indices(img_in)) <: NTuple{2,Base.OneTo} ? typeof(res) <: Array : typeof(res) <: OffsetArray
                res = @inferred(Augmentor.applyeager(MapFun(x->x-Gray{Float32}(0.1)), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
            end
            img = OffsetArray(rgb_rect, -2, -1)
            res = @inferred(Augmentor.applyeager(MapFun(x -> x - RGB(.1,.1,.1)), img))
            @test @inferred(getindex(res,0,0)) isa RGB{Float64}
            @test res == img .- RGB(.1,.1,.1)
            @test typeof(res) <: OffsetArray{RGB{Float64}}
        end
    end
    @testset "affine" begin
        @test Augmentor.supports_affine(MapFun) === false
    end
    @testset "affineview" begin
        @test Augmentor.supports_affineview(MapFun) === false
    end
    @testset "lazy" begin
        @test Augmentor.supports_lazy(MapFun) === true
        res = @inferred(Augmentor.applylazy(MapFun(identity), rect))
        @test res === mappedarray(identity, rect)
        res = @inferred(Augmentor.applylazy(MapFun(identity), rgb_rect))
        @test res === mappedarray(identity, rgb_rect)
        res = @inferred(Augmentor.applylazy(MapFun(x->x-RGB(.1,.1,.1)), rgb_rect))
        @test res == mappedarray(x->x-RGB(.1,.1,.1), rgb_rect)
        res = @inferred(Augmentor.applylazy(MapFun(x->x-RGB(.1,.1,.1)), OffsetArray(rgb_rect,-2,-1)))
        @test indices(res) === (-1:0, 0:2)
        @test @inferred(getindex(res,0,0)) isa RGB{Float64}
        @test res == mappedarray(x->x-RGB(.1,.1,.1), OffsetArray(rgb_rect,-2,-1))
        @test typeof(res) <: MappedArrays.ReadonlyMappedArray{ColorTypes.RGB{Float64}}
    end
    @testset "view" begin
        @test Augmentor.supports_view(MapFun) === false
    end
    @testset "stepview" begin
        @test Augmentor.supports_stepview(MapFun) === false
    end
    @testset "permute" begin
        @test Augmentor.supports_permute(MapFun) === false
    end
end

# --------------------------------------------------------------------

@testset "AggregateThenMapFun" begin
    @test (AggregateThenMapFun <: Augmentor.ImageOperation) == false
    @test (AggregateThenMapFun <: Augmentor.Operation) == true
    @testset "constructor" begin
        @test_throws MethodError AggregateThenMapFun()
        @test_throws MethodError AggregateThenMapFun(x->x)
        @test typeof(@inferred(AggregateThenMapFun(x->x, x->x))) <: AggregateThenMapFun <: Augmentor.Operation
        @test typeof(@inferred(AggregateThenMapFun(mean, identity))) <: AggregateThenMapFun <: Augmentor.Operation
        @test str_show(AggregateThenMapFun(mean, identity)) == "Augmentor.AggregateThenMapFun(mean, identity)"
        @test str_showconst(AggregateThenMapFun(mean, identity)) == "AggregateThenMapFun(mean, identity)"
        @test str_showcompact(AggregateThenMapFun(mean, identity)) == "Map result of \"mean\" using \"identity\" over image"
    end
    @testset "eager" begin
        @test_throws MethodError Augmentor.applyeager(AggregateThenMapFun(mean, identity), nothing)
        @test Augmentor.supports_eager(AggregateThenMapFun) === true
        m = mean(rect)
        res1 = map(x->x-m, rect)
        res2 = map(x->x-m, OffsetArray(rect,0,0))
        imgs = [
            (rect, res1),
            (view(rect,:,:), res1),
            (Augmentor.prepareaffine(rect), res2),
            (OffsetArray(rect, 0, 0), res2),
            (view(rect, IdentityRange(1:2), IdentityRange(1:3)), res2),
        ]
        @testset "single image" begin
            for (img_in, img_out) in imgs
                res = @inferred(Augmentor.applyeager(AggregateThenMapFun(mean, (x,a)->x), img_in))
                @test res == img_in
                @test eltype(res) <: Gray{N0f8}
                @test typeof(indices(img_in)) <: NTuple{2,Base.OneTo} ? typeof(res) <: Array : typeof(res) <: OffsetArray
                res = @inferred(Augmentor.applyeager(AggregateThenMapFun(mean, (x,a)->x-a), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
            end
            img = OffsetArray(rgb_rect, -2, -1)
            res = @inferred(Augmentor.applyeager(AggregateThenMapFun(mean, (x,a)->x-a), img))
            @test res ≈ img .- mean(rgb_rect)
            @test @inferred(getindex(res,0,0)) isa RGB{Float64}
            @test typeof(res) <: OffsetArray{RGB{Float64}}
        end
    end
    @testset "affine" begin
        @test Augmentor.supports_affine(AggregateThenMapFun) === false
    end
    @testset "affineview" begin
        @test Augmentor.supports_affineview(AggregateThenMapFun) === false
    end
    @testset "lazy" begin
        @test Augmentor.supports_lazy(AggregateThenMapFun) === true
        res = @inferred(Augmentor.applylazy(AggregateThenMapFun(mean, (x,a)->x), rect))
        @test res == rect
        @test parent(res) === rect
        @test res isa ReadonlyMappedArray
        res = @inferred(Augmentor.applylazy(AggregateThenMapFun(mean, (x,a)->x-a), rgb_rect))
        @test res == mappedarray(x->x-mean(rgb_rect), rgb_rect)
        @test parent(res) === rgb_rect
        @test typeof(res) <: MappedArrays.ReadonlyMappedArray{ColorTypes.RGB{Float64}}
        img = OffsetArray(rgb_rect, -2, -1)
        res = @inferred(Augmentor.applylazy(AggregateThenMapFun(mean, (x,a)->x-a), img))
        @test res == mappedarray(x->x-mean(rgb_rect), img)
        @test parent(res) === img
        @test typeof(res) <: MappedArrays.ReadonlyMappedArray{ColorTypes.RGB{Float64}}
        @test @inferred(getindex(res,0,0)) isa RGB{Float64}
    end
    @testset "view" begin
        @test Augmentor.supports_view(AggregateThenMapFun) === false
    end
    @testset "stepview" begin
        @test Augmentor.supports_stepview(AggregateThenMapFun) === false
    end
    @testset "permute" begin
        @test Augmentor.supports_permute(AggregateThenMapFun) === false
    end
end
