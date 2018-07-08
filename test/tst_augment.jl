@testset "single op" begin
    @test_throws MethodError augment!(rand(2,2), (rect,), Rotate90())
    @test_throws MethodError augment!((rand(2,2),), rect, Rotate90())
    @test_throws MethodError augment!((rand(2,2),rand(2,2)), (rect,), Rotate90())
    @test_throws BoundsError augment!(rand(2,2), rect, Rotate90())
    for pl in (Augmentor.ImmutablePipeline(Rotate90()), (Rotate90(),))
        img = @inferred Augmentor._augment(rect, pl)
        @test typeof(img) <: Array
        @test img == @inferred(augment(rect, Rotate90()))
        @test img == @inferred(augment(rect, (Rotate90(),)))
        @test eltype(img) <: eltype(rect)
        @test img == rotl90(rect)
        img1, img2 = @inferred augment((square2, rect), pl)
        @test img1 == rotl90(square2)
        @test img2 == img
        @test typeof(img2) == typeof(img)
        img3 = @inferred augment(rect, Rotate90())
        @test img2 == img3
        @test typeof(img3) == typeof(img2)
        out = similar(img)
        @test @inferred(augment!(out, rect, pl)) == img
        outs = (similar(square2), similar(img))
        res = @inferred(augment!(outs, (square2, rect), pl))
        @test res === outs
        @test outs[1] == img1
        @test outs[2] == img2
        out = similar(img)
        @test @inferred(augment!(out, rect, Rotate90())) == img
        @test_throws BoundsError augment!(rand(2,2), rect, pl)
    end
end

ops = Augmentor.ImmutablePipeline(Rotate(90),Rotate(-90)) # forces affine
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) === typeof(invwarpedview(camera, Augmentor.toaffinemap(NoOp(),rect), Flat()))
    @test wv == camera
    wv1, wv2 = @inferred Augmentor._augment((rgb_rect,camera), ops)
    @test typeof(wv1) === typeof(invwarpedview(rgb_rect, Augmentor.toaffinemap(NoOp(),rect), Flat()))
    @test typeof(wv2) === typeof(invwarpedview(camera, Augmentor.toaffinemap(NoOp(),rect), Flat()))
    @test wv1 == rgb_rect
    @test wv2 == camera
end

ops = (CacheImage(),CacheImage()) # forces eager
@testset "$(str_showcompact(ops))" begin
    img = @inferred Augmentor._augment(camera, ops)
    @test img === camera
    img1, img2 = @inferred Augmentor._augment((camera, square2), ops)
    @test img1 === camera
    @test img2 === square2
end

ops = (ElasticDistortion(4,4),CacheImage()) # forces lazy then eager
@testset "$(str_showcompact(ops))" begin
    img = @inferred Augmentor._augment(camera, ops)
    @test size(img) == size(camera)
    @test typeof(img) == typeof(camera)
    img1, img2 = @inferred Augmentor._augment((camera, N0f8.(camera)), ops)
    @test img1 isa Array{Gray{N0f8}}
    @test img2 isa Array{N0f8}
    @test img1 == img2
end

ops = (ShearX(45),ShearX(-45)) # forces affine
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) === typeof(invwarpedview(rect, Augmentor.toaffinemap(NoOp(),rect), Flat()))
    @test view(wv,1:512,1:512) == camera
end

ops = (ShearY(45),ShearY(-45)) # forces affine
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) === typeof(invwarpedview(rect, Augmentor.toaffinemap(NoOp(),rect), Flat()))
    @test view(wv,1:512,1:512) == camera
end

ops = (ShearY(45),ShearX(-2),CacheImage()) # forces affine then eager
@testset "$(str_showcompact(ops))" begin
    img = @inferred Augmentor._augment(camera, ops)
    @test typeof(img) <: OffsetArray
    @test indices(img) == (-255:768, 0:512)
end

ops = (Resize(2,2),Rotate90()) # forces affine
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(rect, ops)
    @test typeof(wv) <: SubArray
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === rect
    @test round.(Float64.(wv),1) == round.(Float64.(rotl90(imresize(rect,2,2))),1)
end

ops = (Resize(2,2),Rotate90(),CacheImage()) # forces affine then eager
@testset "$(str_showcompact(ops))" begin
    img = @inferred Augmentor._augment(rect, ops)
    @test typeof(img) <: OffsetArray
    @test round.(Float64.(img),1) == round.(Float64.(rotl90(imresize(rect,2,2))),1)
end

buf = rand(Gray{N0f8}, 2, 2)
ops = (Resize(2,2),Rotate90(),CacheImage(buf)) # forces affine then eager
@testset "$(str_showcompact(ops))" begin
    img = @inferred Augmentor._augment(rect, ops)
    @test typeof(img) <: OffsetArray
    @test round.(Float64.(img),1) == round.(Float64.(rotl90(imresize(rect,2,2))),1)
    @test img == ops[3].buffer
    @test parent(img) === ops[3].buffer
end

ops = (Rotate180(),Crop(5:200,200:500),Rotate90(1),Crop(1:250, 1:150))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: SubArray
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === camera
    @test_reference "reference/rot_crop_either_crop.txt" wv
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "reference/rot_crop_either_crop.txt" img
    out = similar(img)
    @test @inferred(augment!(out, camera, ops)) === out
    @test_reference "reference/rot_crop_either_crop.txt" out
    @test @allocated(augment!(out, camera, ops)) < @allocated(augment(camera, ops))
end

ops = Augmentor.ImmutablePipeline(Rotate180(),Crop(5:200,200:500),Rotate90(),Crop(50:300, 50:195))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: SubArray
    @test typeof(parent(wv)) <: Base.PermutedDimsArrays.PermutedDimsArray
    @test_reference "reference/rot_crop_rot_crop.txt" wv
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "reference/rot_crop_rot_crop.txt" img
    out = similar(img)
    @test @inferred(augment!(out, camera, ops)) === out
    @test_reference "reference/rot_crop_rot_crop.txt" out
    @test @allocated(augment!(out, camera, ops)) < @allocated(augment(camera, ops))
end

ops = (Rotate180(),Crop(5:200,200:500),Rotate90(),Crop(50:300, 50:195),Resize(25,15))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: SubArray
    @test eltype(wv) <: eltype(camera)
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === camera
    @test_reference "reference/rot_crop_rot_crop_resize.txt" wv
    img = @inferred Augmentor.augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "reference/rot_crop_rot_crop_resize.txt" img
    out = similar(img)
    @test @inferred(augment!(out, camera, ops)) === out
    @test_reference "reference/rot_crop_rot_crop_resize.txt" out
    @test @allocated(augment!(out, camera, ops)) < @allocated(augment(camera, ops))
end

ops = (Rotate(45),CropNative(1:512,1:512))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: SubArray
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === camera
    @test_reference "reference/rot45_crop.txt" wv
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "reference/rot45_crop.txt" img
end

ops = (Rotate(45),CropSize(512,512))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: SubArray
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === camera
    @test_reference "reference/rot45_crop.txt" wv
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "reference/rot45_crop.txt" img
end

ops = (Rotate(-45),CropSize(256,256))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: SubArray
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === camera
    @test_reference "reference/rotr45_cropsize.txt" wv
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "reference/rotr45_cropsize.txt" img
end

ops = (Scale(.1,.2),NoOp())
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: InvWarpedView
    @test parent(wv).itp.coefs === camera
    @test_reference "reference/scale_noop.txt" wv
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "reference/scale_noop.txt" img
end

ops = (Scale(.1,.2),CropRatio())
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: SubArray
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === camera
    @test_reference "reference/scale_cropratio.txt" wv
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "reference/scale_cropratio.txt" img
end

ops = (ShearX(45),NoOp())
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: InvWarpedView
    @test parent(wv).itp.coefs === camera
    @test_reference "reference/shearx_noop.txt" wv
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "reference/shearx_noop.txt" img
end

ops = (ShearY(45),CropNative(1:512,1:512))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: SubArray
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === camera
    @test_reference "reference/sheary_crop.txt" wv
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "reference/sheary_crop.txt" img
end

ops = (Crop(101:200,201:350),Scale(.2,.4))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: SubArray
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === camera
    @test_reference "reference/crop_scale.txt" wv
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "reference/crop_scale.txt" img
end

ops = (Crop(101:200,201:350),Zoom(1.3))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: SubArray
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === camera
    @test_reference "reference/crop_zoom.txt" wv
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "reference/crop_zoom.txt" img
end

ops = (Rotate(45),Zoom(2))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: SubArray
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === camera
    @test_reference "reference/rot45_zoom.txt" wv
    wv2 = Augmentor._augment(camera, (ops..., NoOp()))
    @test_reference "reference/rot45_zoom.txt" wv2
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "reference/rot45_zoom.txt" img
    img1, img2 = @inferred augment((N0f8.(camera),camera), ops)
    @test img1 == img2
    @test img2 == img
    @test img1 isa Array{N0f8}
    @test img2 isa Array{Gray{N0f8}}
    @test_reference "reference/rot45_zoom.txt" img2
end

ops = (Rotate(45),CropSize(200,200),Zoom(1.1),ConvertEltype(RGB{Float64}),SplitChannels())
@testset "$(str_showcompact(ops))" begin
    wv1 = @inferred Augmentor._augment(camera, ops[1:3])
    wv2 = @inferred Augmentor._augment(camera, ops[1:4])
    wv3 = @inferred Augmentor._augment(camera, ops)
    _, wv4 = @inferred Augmentor._augment((rotl90(camera), camera), ops)
    @test wv3 == wv4
    @test typeof(wv3) == typeof(wv4)
    img = colorview(RGB{Float64}, wv3)
    @test RGB{Float64}.(copy(wv1)) ≈ wv2
    @test collect(wv1) ≈ img
    @test_reference "reference/rot45_crop_zoom_convert.txt" wv2
end

# just for code coverage
@test typeof(@inferred(Augmentor.augment_impl(Rotate90()))) <: Expr
