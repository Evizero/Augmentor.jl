reference_path(filename) = joinpath(dirname(@__FILE__), "reference", "$(filename).txt")

function test_reference_impl{T<:Colorant}(filename, img::AbstractArray{T})
    old_color = Base.have_color
    res = try
        eval(Base, :(have_color = true))
        ImageInTerminal.encodeimg(ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), img, 20, 40)[1]
    finally
        eval(Base, :(have_color = $old_color))
    end
    test_reference_impl(filename, res)
end

function test_reference_impl{T<:String}(filename, actual::AbstractArray{T})
    try
        reference = replace.(readlines(reference_path(filename)), ["\n"], [""])
        try
            @assert reference == actual # to throw error
            @test true # to increase test counter if reached
        catch # test failed
            println("Test for \"$filename\" failed.")
            println("- REFERENCE -------------------")
            println.(reference)
            println("-------------------------------")
            println("- ACTUAL ----------------------")
            println.(actual)
            println("-------------------------------")
            if isinteractive()
                print("Replace reference with actual result? [y/n] ")
                answer = first(readline())
                if answer == 'y'
                    write(reference_path(filename), join(actual, "\n"))
                end
            else
                error("You need to run the tests interactively with 'include(\"test/runtests.jl\")' to update reference images")
            end
        end
    catch ex
        if isa(ex, SystemError) # File doesn't exist
            println("Reference file for \"$filename\" does not exist.")
            println("- NEW CONTENT -----------------")
            println.(actual)
            println("-------------------------------")
            if isinteractive()
                print("Create reference file with above content? [y/n] ")
                answer = first(readline())
                if answer == 'y'
                    write(reference_path(filename), join(actual, "\n"))
                end
            else
                error("You need to run the tests interactively with 'include(\"test/runtests.jl\")' to create new reference images")
            end
        else
            throw(ex)
        end
    end
end

# using a macro looks more consistent
macro test_reference(filename, expr)
    esc(:(test_reference_impl($filename, $expr)))
end

# --------------------------------------------------------------------

@testset "single op" begin
    img = @inferred Augmentor._augment(rect, Augmentor.ImmutablePipeline(Rotate90()))
    @test typeof(img) <: Array
    @test typeof(img) == typeof(@inferred(augment(rect, (Rotate90(),))))
    @test eltype(img) <: eltype(rect)
    @test img == rotl90(rect)
    img = @inferred Augmentor._augment(rect, (Rotate90(),))
    @test typeof(img) <: Array
    @test typeof(img) == typeof(@inferred(augment(rect, (Rotate90(),))))
    @test eltype(img) <: eltype(rect)
    @test img == rotl90(rect)
    img = @inferred Augmentor._augment(square, (Rotate(90),))
    @test typeof(img) <: Array
    @test typeof(img) == typeof(@inferred(augment(square, (Rotate(90),))))
    @test eltype(img) <: eltype(square)
    @test img == rotl90(square)
end

ops = Augmentor.ImmutablePipeline(Rotate(90),Rotate(-90)) # forces affine
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) === typeof(invwarpedview(rect, Augmentor.toaffine(NoOp(),rect), Flat()))
    @test wv == camera
end

ops = (CacheImage(),CacheImage()) # forces eager
@testset "$(str_showcompact(ops))" begin
    img = @inferred Augmentor._augment(camera, ops)
    @test img === camera
end

ops = (ElasticDistortion(4,4),CacheImage()) # forces lazy then eager
@testset "$(str_showcompact(ops))" begin
    img = @inferred Augmentor._augment(camera, ops)
    @test size(img) == size(camera)
    @test typeof(img) == typeof(camera)
end

ops = (ShearX(45),ShearX(-45)) # forces affine
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) === typeof(invwarpedview(rect, Augmentor.toaffine(NoOp(),rect), Flat()))
    @test view(wv,1:512,1:512) == camera
end

ops = (ShearY(45),ShearY(-45)) # forces affine
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) === typeof(invwarpedview(rect, Augmentor.toaffine(NoOp(),rect), Flat()))
    @test view(wv,1:512,1:512) == camera
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
    @test_reference "rot_crop_either_crop" wv
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "rot_crop_either_crop" img
end

ops = Augmentor.ImmutablePipeline(Rotate180(),Crop(5:200,200:500),Rotate90(),Crop(50:300, 50:195))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: SubArray
    @test typeof(parent(wv)) <: Base.PermutedDimsArrays.PermutedDimsArray
    @test_reference "rot_crop_rot_crop" wv
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "rot_crop_rot_crop" img
end

ops = (Rotate180(),Crop(5:200,200:500),Rotate90(),Crop(50:300, 50:195),Resize(25,15))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: SubArray
    @test eltype(wv) <: eltype(camera)
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === camera
    @test_reference "rot_crop_rot_crop_resize" wv
    img = @inferred Augmentor.augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "rot_crop_rot_crop_resize" img
end

ops = (Rotate(45),CropNative(1:512,1:512))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: SubArray
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === camera
    @test_reference "rot45_crop" wv
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "rot45_crop" img
end

ops = (Rotate(45),CropSize(512,512))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: SubArray
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === camera
    @test_reference "rot45_crop" wv
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "rot45_crop" img
end

ops = (Rotate(-45),CropSize(256,256))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: SubArray
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === camera
    @test_reference "rotr45_cropsize" wv
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "rotr45_cropsize" img
end

ops = (Scale(.1,.2),NoOp())
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: InvWarpedView
    @test parent(wv).itp.coefs === camera
    @test_reference "scale_noop" wv
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "scale_noop" img
end

ops = (ShearX(45),NoOp())
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: InvWarpedView
    @test parent(wv).itp.coefs === camera
    @test_reference "shearx_noop" wv
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "shearx_noop" img
end

ops = (ShearY(45),CropNative(1:512,1:512))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: SubArray
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === camera
    @test_reference "sheary_crop" wv
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "sheary_crop" img
end

ops = (Crop(101:200,201:350),Scale(.2,.4))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: SubArray
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === camera
    @test_reference "crop_scale" wv
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "crop_scale" img
end

ops = (Crop(101:200,201:350),Zoom(1.3))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: SubArray
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === camera
    @test_reference "crop_zoom" wv
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "crop_zoom" img
end

ops = (Rotate(45),Zoom(2))
@testset "$(str_showcompact(ops))" begin
    wv = @inferred Augmentor._augment(camera, ops)
    @test typeof(wv) <: SubArray
    @test typeof(wv.indexes) <: Tuple{Vararg{IdentityRange}}
    @test typeof(parent(wv)) <: InvWarpedView
    @test parent(parent(wv)).itp.coefs === camera
    @test_reference "rot45_zoom" wv
    wv2 = Augmentor._augment(camera, (ops..., NoOp()))
    @test_reference "rot45_zoom" wv2
    img = @inferred augment(camera, ops)
    @test img == parent(copy(wv))
    @test typeof(img) <: Array
    @test eltype(img) <: eltype(camera)
    @test_reference "rot45_zoom" img
end

# just for code coverage
@test typeof(@inferred(Augmentor.build_pipeline(Rotate90()))) <: Expr
