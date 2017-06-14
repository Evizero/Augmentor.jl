@testset "SplitChannels" begin
    @test (SplitChannels <: Augmentor.AffineOperation) == false
    @test (SplitChannels <: Augmentor.ImageOperation) == false
    @test (SplitChannels <: Augmentor.Operation) == true

    @testset "constructor" begin
        @test typeof(@inferred(SplitChannels())) <: SplitChannels <: Augmentor.Operation
        @test str_show(SplitChannels()) == "Augmentor.SplitChannels()"
        @test str_showconst(SplitChannels()) == "SplitChannels()"
        @test str_showcompact(SplitChannels()) == "Split colorant into its color channels"
    end
    @testset "eager" begin
        @test @inferred(Augmentor.supports_eager(SplitChannels)) === false
        @test_throws MethodError Augmentor.applyeager(SplitChannels(), rand(2,2))
        for img in (Augmentor.prepareaffine(rect), rect, OffsetArray(rect, -2, -1), view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applyeager(SplitChannels(), img)) == reshape(rect, 1, 2, 3)
            @test typeof(Augmentor.applyeager(SplitChannels(), img)) <: Array{N0f8}
        end
        for img in (Augmentor.prepareaffine(rgb_rect), rgb_rect, OffsetArray(rgb_rect, -2, -1), view(rgb_rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applyeager(SplitChannels(), img)) == channelview(rgb_rect)
            @test typeof(Augmentor.applyeager(SplitChannels(), img)) <: Array{N0f8}
        end
    end
    @testset "affine" begin
        @test @inferred(Augmentor.isaffine(SplitChannels)) === false
        @test @inferred(Augmentor.supports_affine(SplitChannels)) === false
    end
    @testset "lazy" begin
        @test @inferred(Augmentor.supports_lazy(SplitChannels)) === true
        @test @inferred(Augmentor.supports_lazy(typeof(SplitChannels()))) === true
        @test_throws MethodError Augmentor.applylazy(SplitChannels(), rand(2,2))
        for img in (Augmentor.prepareaffine(rect), rect, OffsetArray(rect, -2, -1), view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applylazy(SplitChannels(), img)) == reshape(rect, 1, 2, 3)
            if typeof(img) <: Array
                @test typeof(Augmentor.applylazy(SplitChannels(), img)) <: Array{N0f8}
            else
                @test typeof(Augmentor.applylazy(SplitChannels(), img)) <: Base.ReshapedArray
            end
        end
        for img in (Augmentor.prepareaffine(rgb_rect), rgb_rect, OffsetArray(rgb_rect, -2, -1), view(rgb_rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applylazy(SplitChannels(), img)) == channelview(img)
            if typeof(img) <: Array
                @test typeof(Augmentor.applylazy(SplitChannels(), img)) <: Array{N0f8}
            else
                @test typeof(Augmentor.applylazy(SplitChannels(), img)) <: ChannelView
            end
        end
    end
    @testset "view" begin
        @test @inferred(Augmentor.supports_view(SplitChannels)) === false
    end
    @testset "stepview" begin
        @test @inferred(Augmentor.supports_stepview(SplitChannels)) === false
    end
    @testset "permute" begin
        @test @inferred(Augmentor.supports_permute(SplitChannels)) === false
    end
end

# --------------------------------------------------------------------

@testset "CombineChannels" begin
    @test (CombineChannels <: Augmentor.AffineOperation) == false
    @test (CombineChannels <: Augmentor.ImageOperation) == false
    @test (CombineChannels <: Augmentor.Operation) == true

    @testset "constructor" begin
        @test_throws MethodError CombineChannels()
        @test_throws MethodError CombineChannels(Float64)
        @test typeof(@inferred(CombineChannels(RGB))) <: CombineChannels <: Augmentor.Operation
        @test typeof(@inferred(CombineChannels(RGB{N0f8}))) <: CombineChannels <: Augmentor.Operation
        @test str_show(CombineChannels(RGB)) == "Augmentor.CombineChannels(RGB{Any})"
        @test str_show(CombineChannels(Gray{N0f8})) == "Augmentor.CombineChannels(Gray{N0f8})"
        @test str_showconst(CombineChannels(RGB{N0f8})) == "CombineChannels(RGB{N0f8})"
        @test str_showcompact(CombineChannels(Gray)) == "Combine color channels into colorant Gray{Any}"
    end
    @testset "eager" begin
        @test @inferred(Augmentor.supports_eager(CombineChannels)) === false
        @test_throws MethodError Augmentor.applyeager(CombineChannels(RGB), rand(RGB{N0f8},4,4))
        @test_throws MethodError Augmentor.applyeager(CombineChannels(Gray), rand(Gray{N0f8},4,4))
        @test_throws ArgumentError Augmentor.applyeager(CombineChannels(Gray), rand(4,4))
        rect_split = reshape(channelview(rect), 1, 2, 3)
        for img in (rect_split, OffsetArray(rect_split, 0, -2, -1), view(rect_split, 1:1, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applyeager(CombineChannels(Gray), img)) == rect
            @test typeof(Augmentor.applyeager(CombineChannels(Gray), img)) <: Array{Gray{N0f8}}
            @test @inferred(Augmentor.applyeager(CombineChannels(Gray{N0f8}), img)) == rect
            @test typeof(Augmentor.applyeager(CombineChannels(Gray{N0f8}), img)) <: Array{Gray{N0f8}}
        end
        rgb_rect_split = channelview(rgb_rect)
        for img in (rgb_rect_split, OffsetArray(rgb_rect_split, 0, -2, -1), view(rgb_rect_split, 1:3, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applyeager(CombineChannels(RGB), img)) == rgb_rect
            @test typeof(Augmentor.applyeager(CombineChannels(RGB), img)) <: Array{RGB{N0f8}}
            @test @inferred(Augmentor.applyeager(CombineChannels(RGB{N0f8}), img)) == rgb_rect
            @test typeof(Augmentor.applyeager(CombineChannels(RGB{N0f8}), img)) <: Array{RGB{N0f8}}
        end
    end
    @testset "affine" begin
        @test @inferred(Augmentor.isaffine(CombineChannels)) === false
        @test @inferred(Augmentor.supports_affine(CombineChannels)) === false
    end
    @testset "lazy" begin
        @test @inferred(Augmentor.supports_lazy(CombineChannels)) === true
        @test @inferred(Augmentor.supports_lazy(typeof(CombineChannels(Gray)))) === true
        @test_throws MethodError Augmentor.applylazy(CombineChannels(RGB), rand(RGB{N0f8},4,4))
        @test_throws MethodError Augmentor.applylazy(CombineChannels(Gray), rand(Gray{N0f8},4,4))
        @test_throws ArgumentError Augmentor.applylazy(CombineChannels(Gray), rand(4,4))
        rect_split = reshape(channelview(rect), 1, 2, 3)
        for img in (rect_split, OffsetArray(rect_split, 0, -2, -1), view(rect_split, 1:1, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applylazy(CombineChannels(Gray), img)) == rect
            if typeof(img) <: Array
                @test typeof(Augmentor.applylazy(CombineChannels(Gray), img)) <: Array{Gray{N0f8}}
            else
                @test typeof(Augmentor.applylazy(CombineChannels(Gray), img)) <: ColorView{Gray{N0f8}}
            end
        end
        rgb_rect_split = channelview(rgb_rect)
        for img in (rgb_rect_split, OffsetArray(rgb_rect_split, 0, -2, -1), view(rgb_rect_split, 1:3, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applylazy(CombineChannels(RGB), img)) == colorview(RGB, img)
            if typeof(img) <: Array
                @test typeof(Augmentor.applylazy(CombineChannels(RGB), img)) <: Array{RGB{N0f8}}
            else
                @test typeof(Augmentor.applylazy(CombineChannels(RGB), img)) <: ColorView{RGB{N0f8}}
            end
        end
    end
    @testset "view" begin
        @test @inferred(Augmentor.supports_view(CombineChannels)) === false
    end
    @testset "stepview" begin
        @test @inferred(Augmentor.supports_stepview(CombineChannels)) === false
    end
    @testset "permute" begin
        @test @inferred(Augmentor.supports_permute(CombineChannels)) === false
    end
end

# --------------------------------------------------------------------

@testset "PermuteDims" begin
    @test (PermuteDims <: Augmentor.AffineOperation) == false
    @test (PermuteDims <: Augmentor.ImageOperation) == false
    @test (PermuteDims <: Augmentor.Operation) == true

    @testset "constructor" begin
        @test_throws MethodError PermuteDims()
        @test_throws MethodError PermuteDims(())
        @test_throws MethodError PermuteDims(Float64)
        @test_throws ArgumentError PermuteDims((2,2))
        @test_throws ArgumentError PermuteDims(2,2)
        @test typeof(PermuteDims(1,2)) <: PermuteDims{2} <: Augmentor.Operation
        @test typeof(PermuteDims((1,2))) <: PermuteDims{2} <: Augmentor.Operation
        @test typeof(PermuteDims(1)) <: PermuteDims{1} <: Augmentor.Operation
        @test typeof(PermuteDims((1,))) <: PermuteDims{1} <: Augmentor.Operation
        @test typeof(PermuteDims((1,2))) <: PermuteDims{2} <: Augmentor.Operation
        @test typeof(PermuteDims((3,1,2))) <: PermuteDims{3} <: Augmentor.Operation
        @test str_show(PermuteDims((1,))) == "Augmentor.PermuteDims((1,))"
        @test str_show(PermuteDims((1,2))) == "Augmentor.PermuteDims((1,$(SPACE)2))"
        @test str_showconst(PermuteDims((1,3,2))) == "PermuteDims(1, 3, 2)"
        @test str_showcompact(PermuteDims((3,2,1))) == "Permute dimension order to (3,$(SPACE)2,$(SPACE)1)"
    end
    @testset "eager" begin
        @test @inferred(Augmentor.supports_eager(PermuteDims)) === true
        @test @inferred(Augmentor.supports_eager(typeof(PermuteDims(2,1)))) === true
        for img in (Augmentor.prepareaffine(rect), rect, OffsetArray(rect, -2, -1), view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test_throws MethodError Augmentor.applyeager(PermuteDims(3,2,1), img)
            @test @inferred(Augmentor.applyeager(PermuteDims(2,1), img)) == permutedims(img, (2,1))
            @test typeof(Augmentor.applyeager(PermuteDims(2,1), img)) == typeof(permutedims(img, (2,1)))
        end
    end
    @testset "affine" begin
        @test @inferred(Augmentor.isaffine(PermuteDims)) === false
        @test @inferred(Augmentor.supports_affine(PermuteDims)) === false
    end
    @testset "lazy" begin
        @test @inferred(Augmentor.supports_lazy(PermuteDims)) === true
        @test @inferred(Augmentor.supports_lazy(typeof(PermuteDims(2,1)))) === true
        for img in (Augmentor.prepareaffine(rect), rect, OffsetArray(rect, -2, -1), view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test_throws MethodError Augmentor.applylazy(PermuteDims(3,2,1), img)
            @test @inferred(Augmentor.applylazy(PermuteDims(2,1), img)) === permuteddimsview(img, (2,1))
        end
    end
    @testset "view" begin
        @test @inferred(Augmentor.supports_view(PermuteDims)) === false
    end
    @testset "stepview" begin
        @test @inferred(Augmentor.supports_stepview(PermuteDims)) === false
    end
    @testset "permute" begin
        @test @inferred(Augmentor.supports_permute(PermuteDims)) === false
    end
end

# --------------------------------------------------------------------

@testset "Reshape" begin
    @test (Reshape <: Augmentor.AffineOperation) == false
    @test (Reshape <: Augmentor.ImageOperation) == false
    @test (Reshape <: Augmentor.Operation) == true

    @testset "constructor" begin
        @test_throws MethodError Reshape()
        @test_throws MethodError Reshape(())
        @test_throws MethodError Reshape(Float64)
        @test_throws MethodError Reshape(1.,2.)
        @test typeof(Reshape(2,2)) <: Reshape{2} <: Augmentor.Operation
        @test typeof(Reshape(1,2)) <: Reshape{2} <: Augmentor.Operation
        @test typeof(Reshape((1,2))) <: Reshape{2} <: Augmentor.Operation
        @test typeof(Reshape(1)) <: Reshape{1} <: Augmentor.Operation
        @test typeof(Reshape((1,))) <: Reshape{1} <: Augmentor.Operation
        @test typeof(Reshape((1,2))) <: Reshape{2} <: Augmentor.Operation
        @test typeof(Reshape((3,1,2))) <: Reshape{3} <: Augmentor.Operation
        @test str_show(Reshape((1,))) == "Augmentor.Reshape{1}((1,))"
        @test str_show(Reshape((1,2))) == "Augmentor.Reshape{2}((1,$(SPACE)2))"
        @test str_showconst(Reshape((1,3,2))) == "Reshape(1, 3, 2)"
        @test str_showcompact(Reshape((3,2,1))) == "Reshape array to 3×2×1"
        @test str_showcompact(Reshape(10)) == "Reshape array to 10-element vector"
    end
    @testset "eager" begin
        @test @inferred(Augmentor.supports_eager(Reshape)) === false
        @test @inferred(Augmentor.supports_eager(typeof(Reshape(2,1)))) === false
        # FIXME: reintroduce Augmentor.prepareaffine(rect) in 0.6
        for img in (rect, OffsetArray(rect, -2, -1), view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applyeager(Reshape(3,2,1), img)) == reshape(img, (3,2,1))
            @test typeof(Augmentor.applyeager(Reshape(3,2,1), img)) <: Array{Gray{N0f8}}
        end
    end
    @testset "affine" begin
        @test @inferred(Augmentor.isaffine(Reshape)) === false
        @test @inferred(Augmentor.supports_affine(Reshape)) === false
    end
    @testset "lazy" begin
        @test @inferred(Augmentor.supports_lazy(Reshape)) === true
        @test @inferred(Augmentor.supports_lazy(typeof(Reshape(2,1)))) === true
        # FIXME: reintroduce Augmentor.prepareaffine(rect) in 0.6
        for img in (rect, OffsetArray(rect, -2, -1), view(rect, IdentityRange(1:2), IdentityRange(1:3)))
            @test @inferred(Augmentor.applylazy(Reshape(3,2,1), img)) == reshape(img, (3,2,1))
            if typeof(img) <: Array
                @test typeof(Augmentor.applylazy(Reshape(3,2,1), img)) <: Array{Gray{N0f8}}
            else
                @test typeof(Augmentor.applylazy(Reshape(3,2,1), img)) <: Base.ReshapedArray
            end
        end
    end
    @testset "view" begin
        @test @inferred(Augmentor.supports_view(Reshape)) === false
    end
    @testset "stepview" begin
        @test @inferred(Augmentor.supports_stepview(Reshape)) === false
    end
    @testset "permute" begin
        @test @inferred(Augmentor.supports_permute(Reshape)) === false
    end
end
