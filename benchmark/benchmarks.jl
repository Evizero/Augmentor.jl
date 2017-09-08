using Augmentor, Images, TestImages
using PkgBenchmark

pattern = testpattern()
affpattern = Augmentor.prepareaffine(pattern)
camera = testimage("cameraman")
cameras = similar(camera, size(camera)..., 2)
copy!(view(cameras,:,:,1), camera)
copy!(view(cameras,:,:,2), camera)

# compile the gauss filter (takes a couple seconds)
Augmentor.applyeager(ElasticDistortion(10), pattern)

shortname(op) = typeof(op).name.name

# missing: CombineChannels, CacheImageInto
@benchgroup "applyeager" ["eager", "operations"] begin
    for op in [
            NoOp(),
            FlipX(), FlipY(),
            ShearX(5), ShearY(5),
            Either((Rotate90(), Rotate270()), (1,0)),
            Rotate90(), Rotate180(), Rotate270(),
            Rotate(45),
            Crop(1:100,1:100),
            CropNative(1:100,1:100),
            CropSize(100,100),
            CropRatio(1), RCropRatio(1),
            Scale(1.1), Zoom(1.1),
            Resize(100,100),
            ConvertEltype(Gray),
            CacheImage(),
            ElasticDistortion(10),
            SplitChannels(),
            Reshape(400,300),
            PermuteDims(2,1),
        ]
        @bench "$(shortname(op))" Augmentor.applyeager($op, $pattern)
    end
end

@benchgroup "applylazy" ["lazy", "operations"] begin
    for op in [
            NoOp(),
            FlipX(), FlipY(),
            ShearX(5), ShearY(5),
            Either((Rotate90(), Rotate270()), (1,0)),
            Rotate90(), Rotate180(), Rotate270(),
            Rotate(45),
            Crop(1:100,1:100),
            CropNative(1:100,1:100),
            CropSize(100,100),
            CropRatio(1), RCropRatio(1),
            Scale(1.1), Zoom(1.1),
            Resize(100,100),
            ConvertEltype(Gray),
            ElasticDistortion(10),
            SplitChannels(),
            Reshape(400,300),
            PermuteDims(2,1),
        ]
        @bench "$(shortname(op))" Augmentor.plain_array(Augmentor.applylazy($op, $pattern))
    end
end

@benchgroup "applyaffine" ["affine", "lazy", "operations"] begin
    for op in [
            NoOp(),
            FlipX(), FlipY(),
            ShearX(5), ShearY(5),
            Either((Rotate90(), Rotate270()), (1,0)),
            Rotate90(), Rotate180(), Rotate270(),
            Rotate(45),
            Scale(1.1),
        ]
        @bench "$(shortname(op))" Augmentor.plain_array(Augmentor.applyaffine($op, $affpattern))
    end
end

@benchgroup "applyaffineview" ["affine", "lazy", "operations"] begin
    for op in [
            NoOp(),
            FlipX(), FlipY(),
            ShearX(5), ShearY(5),
            Either((Rotate90(), Rotate270()), (1,0)),
            Rotate90(), Rotate180(), Rotate270(),
            Rotate(45),
            Crop(1:100,1:100),
            CropNative(1:100,1:100),
            CropSize(100,100),
            CropRatio(1), RCropRatio(1),
            Scale(1.1), Zoom(1.1),
            Resize(100,100),
        ]
        @bench "$(shortname(op))" Augmentor.plain_array(Augmentor.applyaffineview($op, $affpattern))
    end
end
