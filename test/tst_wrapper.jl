@testset "Mask" begin
    @testset "unwrap" begin
        img = testpattern()
        m = Augmentor.Mask(img)
        @test Augmentor.unwrap(m) === img
    end
end

@testset "shouldapply" begin
    @testset "type arguments" begin
        ops = [Rotate90(), ColorJitter()]
        whats = [Augmentor.Mask(testpattern())]
        for op in ops, what in whats
            @test Augmentor.shouldapply(op, what) == Augmentor.shouldapply(typeof(op), typeof(what))
        end
    end

    @testset "affine operations" begin
        ops = [FlipX, FlipY, NoOp, Rotate, Rotate180, Rotate270, Rotate90,
               Scale, ShearX, ShearY]
        applicable = [Augmentor.Mask]
        notapplicable = []
        for op in ops
            for what in applicable
                @test Augmentor.shouldapply(op, what) == Val(true)
            end
            for what in notapplicable
                @test Augmentor.shouldapply(op, what) == Val(false)
            end
        end
    end

    @testset "color operations" begin
        ops = [ColorJitter, GaussianBlur]
        applicable = []
        notapplicable = [Augmentor.Mask]
        for op in ops
            for what in applicable
                @test Augmentor.shouldapply(op, what) == Val(true)
            end
            for what in notapplicable
                @test Augmentor.shouldapply(op, what) == Val(false)
            end
        end
    end
end

