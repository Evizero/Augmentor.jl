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
        for img in (Augmentor.prepareaffine(rect), rect, view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            res = @inferred(Augmentor.applyeager(MapFun(identity), img))
            @test res == rect
            @test typeof(res) <: Array{eltype(img)}
            res = @inferred(Augmentor.applyeager(MapFun(x->x .- Gray(0.1)), img))
            @test res ≈ rect .- 0.1
            @test typeof(res) <: Array{Gray{Float64}}
        end
        img = OffsetArray(rect, -2, -1)
        res = @inferred(Augmentor.applyeager(MapFun(identity), img))
        @test res == rect
        @test typeof(res) <: Array{eltype(img)}
        img = OffsetArray(rgb_rect, -2, -1)
        res = @inferred(Augmentor.applyeager(MapFun(x -> x - RGB(.1,.1,.1)), img))
        @test res == rgb_rect .- RGB(.1,.1,.1)
        @test typeof(res) <: Array{RGB{Float64}}
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
        for img in (Augmentor.prepareaffine(rect), rect, view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            res = @inferred(Augmentor.applyeager(AggregateThenMapFun(mean, (x,a)->x), img))
            @test res == rect
            @test typeof(res) <: Array{eltype(img)}
            res = @inferred(Augmentor.applyeager(AggregateThenMapFun(mean, (x,a)->x-a), img))
            @test res ≈ rect .- mean(rect)
            @test typeof(res) <: Array{Gray{Float64}}
        end
        img = OffsetArray(rect, -2, -1)
        res = @inferred(Augmentor.applyeager(AggregateThenMapFun(mean, (x,a)->x), img))
        @test res == rect
        @test typeof(res) <: Array{eltype(img)}
        img = OffsetArray(rgb_rect, -2, -1)
        res = @inferred(Augmentor.applyeager(AggregateThenMapFun(mean, (x,a)->x-a), img))
        @test res == rgb_rect .- mean(rgb_rect)
        @test typeof(res) <: Array{RGB{Float64}}
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
        @test res isa ReadonlyMappedArray
        res = @inferred(Augmentor.applylazy(AggregateThenMapFun(mean, (x,a)->x-a), rgb_rect))
        @test res == mappedarray(x->x-mean(rgb_rect), rgb_rect)
        @test typeof(res) <: MappedArrays.ReadonlyMappedArray{ColorTypes.RGB{Float64}}
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
