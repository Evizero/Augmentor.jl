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
        @test Augmentor.supports_eager(SplitChannels) === false
        @test_throws MethodError Augmentor.applyeager(SplitChannels(), rand(2,2))
        res1 = channelview(reshape(rect, 1, 2, 3))
        res2 = channelview(rgb_rect)
        imgs = [
            (rect, res1),
            (Augmentor.prepareaffine(rect), res1),
            (OffsetArray(rect, -2, -1), res1),
            (view(rect, IdentityRange(1:2), IdentityRange(1:3)), res1),
            (rgb_rect, res2),
            (Augmentor.prepareaffine(rgb_rect), res2),
            (OffsetArray(rgb_rect, -2, -1), res2),
            (view(rgb_rect, IdentityRange(1:2), IdentityRange(1:3)), res2),
        ]
        @testset "single image" begin
            for (img_in, img_out) in imgs
                res = @inferred(Augmentor.applyeager(SplitChannels(), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
            end
        end
        @testset "multiple images" begin
            for (img_in1, img_out1) in imgs, (img_in2, img_out2) in imgs
                img_in = (img_in1, img_in2)
                img_out = (img_out1, img_out2)
                res = @inferred(Augmentor.applyeager(SplitChannels(), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
            end
        end
    end
    @testset "affine" begin
        @test Augmentor.supports_affine(SplitChannels) === false
    end
    @testset "affineview" begin
        @test Augmentor.supports_affineview(SplitChannels) === false
    end
    @testset "lazy" begin
        @test Augmentor.supports_lazy(SplitChannels) === true
        @test @inferred(Augmentor.supports_lazy(typeof(SplitChannels()))) === true
        @test_throws MethodError Augmentor.applylazy(SplitChannels(), rand(2,2))
        f1 = img->reshape(channelview(img), 1, 2, 3)
        f2 = img->Augmentor.plain_indices(channelview(img))
        imgs = [
            (rect, f1),
            (Augmentor.prepareaffine(rect), f1),
            (OffsetArray(rect, -2, -1), f1),
            (view(rect, IdentityRange(1:2), IdentityRange(1:3)), f1),
            (rgb_rect, f2),
            (Augmentor.prepareaffine(rgb_rect), f2),
            (OffsetArray(rgb_rect, -2, -1), f2),
            (view(rgb_rect, IdentityRange(1:2), IdentityRange(1:3)), f2),
        ]
        @testset "single image" begin
            for (img_in, f) in imgs
                img_out = f(img_in)
                res = @inferred(Augmentor.applylazy(SplitChannels(), img_in))
                @test res == img_out
                @test res == Augmentor.applyeager(SplitChannels(), img_in)
                @test typeof(res) == typeof(img_out)
            end
        end
        @testset "multiple images" begin
            for (img_in1, f1) in imgs, (img_in2, f2) in imgs
                img_out1 = f1(img_in1)
                img_out2 = f2(img_in2)
                img_in = (img_in1, img_in2)
                img_out = (img_out1, img_out2)
                res = @inferred(Augmentor.applylazy(SplitChannels(), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
            end
        end
    end
    @testset "view" begin
        @test Augmentor.supports_view(SplitChannels) === false
    end
    @testset "stepview" begin
        @test Augmentor.supports_stepview(SplitChannels) === false
    end
    @testset "permute" begin
        @test Augmentor.supports_permute(SplitChannels) === false
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
        @test Augmentor.supports_eager(CombineChannels) === false
        @test_throws MethodError Augmentor.applyeager(CombineChannels(RGB), rand(RGB{N0f8},4,4))
        @test_throws MethodError Augmentor.applyeager(CombineChannels(Gray), rand(Gray{N0f8},4,4))
        @test_throws ArgumentError Augmentor.applyeager(CombineChannels(Gray), rand(4,4))
        @test_throws MethodError Augmentor.applyeager(CombineChannels(RGB), (rand(3,4,4), rand(RGB{N0f8},4,4)))
        @test_throws MethodError Augmentor.applyeager(CombineChannels(Gray), (rand(1,4,4), rand(Gray{N0f8},4,4)))
        @test_throws ArgumentError Augmentor.applyeager(CombineChannels(Gray), (rand(1,4,4), rand(4,4)))
        rect_split = reshape(channelview(rect), 1, 2, 3)
        rgb_rect_split = channelview(rgb_rect)
        imgs = [
            (rect_split, rect),
            (reshape(channelview(Augmentor.prepareaffine(rect)), 1, 2, 3), rect),
            (OffsetArray(rect_split, 0, -2, -1), rect),
            (view(rect_split, 1:1, IdentityRange(1:2), IdentityRange(1:3)), rect),
        ]
        rgb_imgs = [
            (rgb_rect_split, rgb_rect),
            (channelview(Augmentor.prepareaffine(rgb_rect)), rgb_rect),
            (OffsetArray(rgb_rect_split, 0, -2, -1), rgb_rect),
            (view(rgb_rect_split, IdentityRange(1:3), IdentityRange(1:2), IdentityRange(1:3)), rgb_rect),
        ]
        @testset "single image" begin
            for (img_in, img_out) in imgs
                res = @inferred(Augmentor.applyeager(CombineChannels(Gray), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
                @test typeof(res) <: Array{Gray{N0f8}}
                res = @inferred(Augmentor.applyeager(CombineChannels(Gray{N0f8}), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
                @test typeof(res) <: Array{Gray{N0f8}}
            end
            for (img_in, img_out) in rgb_imgs
                res = @inferred(Augmentor.applyeager(CombineChannels(RGB), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
                @test typeof(res) <: Array{RGB{N0f8}}
                res = @inferred(Augmentor.applyeager(CombineChannels(RGB{N0f8}), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
                @test typeof(res) <: Array{RGB{N0f8}}
            end
        end
        @testset "multiple images" begin
            for (img_in1, img_out1) in imgs, (img_in2, img_out2) in imgs
                img_in = (img_in1, img_in2)
                img_out = (img_out1, img_out2)
                res = @inferred(Augmentor.applyeager(CombineChannels(Gray), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
                res = @inferred(Augmentor.applyeager(CombineChannels(Gray{N0f8}), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
            end
            for (img_in1, img_out1) in rgb_imgs, (img_in2, img_out2) in rgb_imgs
                img_in = (img_in1, img_in2)
                img_out = (img_out1, img_out2)
                res = @inferred(Augmentor.applyeager(CombineChannels(RGB), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
                res = @inferred(Augmentor.applyeager(CombineChannels(RGB{N0f8}), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
            end
        end
    end
    @testset "affine" begin
        @test Augmentor.supports_affine(CombineChannels) === false
    end
    @testset "affineview" begin
        @test Augmentor.supports_affineview(CombineChannels) === false
    end
    @testset "lazy" begin
        @test Augmentor.supports_lazy(CombineChannels) === true
        @test @inferred(Augmentor.supports_lazy(typeof(CombineChannels(Gray)))) === true
        @test_throws MethodError Augmentor.applylazy(CombineChannels(RGB), rand(RGB{N0f8},4,4))
        @test_throws MethodError Augmentor.applylazy(CombineChannels(Gray), rand(Gray{N0f8},4,4))
        @test_throws ArgumentError Augmentor.applylazy(CombineChannels(Gray), rand(4,4))
        @test_throws MethodError Augmentor.applylazy(CombineChannels(RGB), (rand(3,4,4), rand(RGB{N0f8},4,4)))
        @test_throws MethodError Augmentor.applylazy(CombineChannels(Gray), (rand(1,4,4), rand(Gray{N0f8},4,4)))
        @test_throws ArgumentError Augmentor.applylazy(CombineChannels(Gray), (rand(1,4,4), rand(4,4)))
        rect_split = reshape(channelview(rect), 1, 2, 3)
        rgb_rect_split = channelview(rgb_rect)
        f1 = (T, img) -> colorview(T, reshape(img, 2, 3))
        f2 = (T, img) -> colorview(T, Augmentor.plain_indices(img))
        imgs = [
            (rect_split),
            (reshape(channelview(Augmentor.prepareaffine(rect)), 1, 2, 3)),
            (OffsetArray(rect_split, 0, -2, -1)),
            (view(rect_split, 1:1, IdentityRange(1:2), IdentityRange(1:3))),
        ]
        rgb_imgs = [
            (rgb_rect_split),
            (channelview(Augmentor.prepareaffine(rgb_rect))),
            (OffsetArray(rgb_rect_split, 0, -2, -1)),
            (view(rgb_rect_split, 1:3, IdentityRange(1:2), IdentityRange(1:3))),
        ]
        @testset "single image" begin
            for img_in in imgs, T in (Gray, Gray{N0f8})
                img_out = f1(T, img_in)
                res = @inferred(Augmentor.applylazy(CombineChannels(T), img_in))
                @test res == img_out
                @test res == Augmentor.applyeager(CombineChannels(T), img_in)
                @test typeof(res) == typeof(img_out)
                @test eltype(res) == Gray{N0f8}
            end
            for img_in in rgb_imgs, T in (RGB, RGB{N0f8})
                img_out = f2(T, img_in)
                res = @inferred(Augmentor.applylazy(CombineChannels(T), img_in))
                @test res == img_out
                @test res == Augmentor.applyeager(CombineChannels(T), img_in)
                @test typeof(res) == typeof(img_out)
                @test eltype(res) == RGB{N0f8}
            end
        end
        @testset "multiple images" begin
            for img_in1 in imgs, img_in2 in imgs, T in (Gray, Gray{N0f8})
                img_in = (img_in1, img_in2)
                img_out = f1.(T, img_in)
                res = @inferred(Augmentor.applylazy(CombineChannels(T), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
                @test map(eltype,res) == (Gray{N0f8}, Gray{N0f8})
            end
            for img_in1 in rgb_imgs, img_in2 in rgb_imgs, T in (RGB, RGB{N0f8})
                img_in = (img_in1, img_in2)
                img_out = f2.(T, img_in)
                res = @inferred(Augmentor.applylazy(CombineChannels(T), img_in))
                @test res == img_out
                @test typeof(res) == typeof(img_out)
                @test map(eltype,res) == (RGB{N0f8}, RGB{N0f8})
            end
        end
    end
    @testset "view" begin
        @test Augmentor.supports_view(CombineChannels) === false
    end
    @testset "stepview" begin
        @test Augmentor.supports_stepview(CombineChannels) === false
    end
    @testset "permute" begin
        @test Augmentor.supports_permute(CombineChannels) === false
    end
end
