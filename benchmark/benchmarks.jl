using BenchmarkTools
using Augmentor, Images, TestImages

const SUITE = BenchmarkGroup()

pattern = testpattern()
affpattern = Augmentor.prepareaffine(pattern)
camera = testimage("cameraman")
cameras = similar(camera, size(camera)..., 2)
copy!(view(cameras,:,:,1), camera)
copy!(view(cameras,:,:,2), camera)

# compile the gauss filter (takes a couple seconds)
Augmentor.applyeager(ElasticDistortion(10), pattern)

shortname(op) = string(typeof(op).name.name)

# missing: CombineChannels, CacheImageInto
SUITE["applyeager"] = BenchmarkGroup(["eager", "operations"])
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
    SUITE["applyeager"][shortname(op)] = @benchmarkable Augmentor.applyeager($op, $pattern)
end

SUITE["applylazy"] = BenchmarkGroup(["lazy", "operations"])
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
    SUITE["applylazy"][shortname(op)] = @benchmarkable Augmentor.plain_array(Augmentor.applylazy($op, $pattern))
end

SUITE["applyaffine"] = BenchmarkGroup(["affine", "lazy", "operations"])
for op in [
        NoOp(),
        FlipX(), FlipY(),
        ShearX(5), ShearY(5),
        Either((Rotate90(), Rotate270()), (1,0)),
        Rotate90(), Rotate180(), Rotate270(),
        Rotate(45),
        Scale(1.1),
    ]
    SUITE["applyaffine"][shortname(op)] = @benchmarkable Augmentor.plain_array(Augmentor.applyaffine($op, $affpattern))
end

SUITE["applyaffineview"] = BenchmarkGroup(["affine", "lazy", "operations"])
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
    SUITE["applyaffineview"][shortname(op)] = @benchmarkable Augmentor.plain_array(Augmentor.applyaffineview($op, $affpattern))
end

grp = SUITE["augment"] = BenchmarkGroup(["-"])
pl = ShearX(10)
grp["affine1"] = @benchmarkable augment($pattern, $pl)
pl = ShearX(10) |> ShearX(-10)
grp["affine2"] = @benchmarkable augment($pattern, $pl)
pl = ShearX(10) |> ShearX(-10) |> ShearY(10) |> ShearY(-10)
grp["affine3"] = @benchmarkable augment($pattern, $pl)
pl = Rotate180() |> Rotate90(1)
grp["lazyrotate"] = @benchmarkable augment($pattern, $pl)
pl = Rotate180() |> Crop(5:200,100:400) |> Rotate90(1) |> Crop(1:250,1:150)
grp["lazycrop"] = @benchmarkable augment($pattern, $pl)
pl = Resize(100,100) |> Resize(200,400) |> Resize(20,20) |> Resize(100,100)
grp["resize"] = @benchmarkable augment($pattern, $pl)

grp = SUITE["augment!"] = BenchmarkGroup(["-"])
pl = Rotate180() |> Rotate90()
out = similar(pattern, 400, 300)
grp["lazyrotate"] = @benchmarkable augment!($out, $pattern, $pl)
pl = Resize(100,100) |> Resize(200,400) |> Resize(20,20) |> Resize(100,100)
out = similar(pattern, 100, 100)
grp["resize"] = @benchmarkable augment!($out, $pattern, $pl)
