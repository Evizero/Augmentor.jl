ops = (Rotate180(),Crop(5:200,200:500),Rotate90(1),Crop(1:250, 1:150))
@testset "$(str_showcompact(ops))" begin
    @test_throws ArgumentError augmentbatch!(similar(camera, 250, 150, 3), cameras, ops)
    @test_throws DimensionMismatch augmentbatch!(similar(camera, 250, 140, 2), cameras, ops)
    out = similar(camera, 250, 150, 2)
    @test @inferred(augmentbatch!(out, cameras, ops)) === out
    @test typeof(out) <: Array
    @test eltype(out) <: eltype(camera)
    @test_reference "rot_crop_either_crop" out[:,:,1]
    @test_reference "rot_crop_either_crop" out[:,:,2]
    out = similar(camera, 250, 150, 2)
    @test @inferred(augmentbatch!(out, cameras, Augmentor.ImmutablePipeline(ops))) === out
    @test typeof(out) <: Array
    @test eltype(out) <: eltype(camera)
    @test_reference "rot_crop_either_crop" out[:,:,1]
    @test_reference "rot_crop_either_crop" out[:,:,2]
    out = similar(camera, 250, 150, 2)
    @test @inferred(augmentbatch!(out, collect.(obsview(cameras)), ops)) === out
    @test typeof(out) <: Array
    @test eltype(out) <: eltype(camera)
    @test_reference "rot_crop_either_crop" out[:,:,1]
    @test_reference "rot_crop_either_crop" out[:,:,2]
    outs = [similar(camera, 250, 150), similar(camera, 250, 150)]
    @test @inferred(augmentbatch!(outs, cameras, ops)) === outs
    @test typeof(outs) <: Vector
    @test eltype(outs) <: Array{eltype(camera)}
    @test_reference "rot_crop_either_crop" outs[1]
    @test_reference "rot_crop_either_crop" outs[2]
    out = similar(camera, 2, 250, 150)
    cameras_t = permutedims(cameras, (3,1,2))
    @test @inferred(augmentbatch!(out, cameras_t, ops, ObsDim.First())) === out
    @test typeof(out) <: Array
    @test eltype(out) <: eltype(camera)
    @test_reference "rot_crop_either_crop" out[1,:,:]
    @test_reference "rot_crop_either_crop" out[2,:,:]
end

@testset "Multithreaded: $(str_showcompact(ops))" begin
    @test_throws ArgumentError augmentbatch!(CPUThreads(), similar(camera, 250, 150, 3), cameras, ops)
    # doesn't work because exception is thrown in thread
    # @test_throws DimensionMismatch augmentbatch!(CPUThreads(), similar(camera, 250, 140, 2), cameras, ops)
    out = similar(camera, 250, 150, 2)
    @test @inferred(augmentbatch!(CPUThreads(), out, cameras, ops)) === out
    @test typeof(out) <: Array
    @test eltype(out) <: eltype(camera)
    @test_reference "rot_crop_either_crop" out[:,:,1]
    @test_reference "rot_crop_either_crop" out[:,:,2]
    out = similar(camera, 250, 150, 2)
    @test @inferred(augmentbatch!(CPUThreads(), out, cameras, Augmentor.ImmutablePipeline(ops))) === out
    @test typeof(out) <: Array
    @test eltype(out) <: eltype(camera)
    @test_reference "rot_crop_either_crop" out[:,:,1]
    @test_reference "rot_crop_either_crop" out[:,:,2]
    out = similar(camera, 250, 150, 2)
    @test @inferred(augmentbatch!(CPUThreads(), out, collect.(obsview(cameras)), ops)) === out
    @test typeof(out) <: Array
    @test eltype(out) <: eltype(camera)
    @test_reference "rot_crop_either_crop" out[:,:,1]
    @test_reference "rot_crop_either_crop" out[:,:,2]
    outs = [similar(camera, 250, 150), similar(camera, 250, 150)]
    @test @inferred(augmentbatch!(CPUThreads(), outs, cameras, ops)) === outs
    @test typeof(outs) <: Vector
    @test eltype(outs) <: Array{eltype(camera)}
    @test_reference "rot_crop_either_crop" outs[1]
    @test_reference "rot_crop_either_crop" outs[2]
    out = similar(camera, 2, 250, 150)
    cameras_t = permutedims(cameras, (3,1,2))
    @test @inferred(augmentbatch!(CPUThreads(), out, cameras_t, ops, ObsDim.First())) === out
    @test typeof(out) <: Array
    @test eltype(out) <: eltype(camera)
    @test_reference "rot_crop_either_crop" out[1,:,:]
    @test_reference "rot_crop_either_crop" out[2,:,:]
end

ops = Rotate90()
@testset "$(str_showcompact(ops))" begin
    out = similar(camera, 512, 512, 2)
    @test @inferred(augmentbatch!(out, cameras, ops)) === out
end
