function sum_border(A::AbstractArray{Float64,3})
    s = 0.
    ndim, h, w = size(A)
    for i = 1:h, j = 1:w
        if i == 1 || j == 1 || i == h || j == w
            for d = 1:ndim
                s += abs(A[d, i, j])
            end
        end
    end
    s
end

@testset "uniform_field" begin
    @test_throws UndefVarError uniform_field
    @test typeof(Augmentor.uniform_field) <: Function

    A = @inferred Augmentor.uniform_field(5, 6)
    @test typeof(A) <: Array{Float64}
    @test size(A) === (2, 5, 6)
    @test sum_border(A) == 0.
    @test 2.5 > mapreduce(abs, +, A) > 0.

    A = @inferred Augmentor.uniform_field(5, 6, .5, false, true)
    @test typeof(A) <: Array{Float64}
    @test size(A) === (2, 5, 6)
    @test sum_border(A) == 0.
    @test mapreduce(abs, +, A) > 2.5

    A = Augmentor.uniform_field(5, 6, scale=.5)
    @test typeof(A) <: Array{Float64}
    @test size(A) === (2, 5, 6)
    @test sum_border(A) == 0.
    @test mapreduce(abs, +, A) > 2.5

    A = @inferred Augmentor.uniform_field(5, 6, .5, true, true)
    @test typeof(A) <: Array{Float64}
    @test size(A) === (2, 5, 6)
    @test sum_border(A) != 0.
    @test mapreduce(abs, +, A) > 2.5

    A = Augmentor.uniform_field(5, 6, scale=.5, border=true)
    @test typeof(A) <: Array{Float64}
    @test size(A) === (2, 5, 6)
    @test sum_border(A) != 0.
    @test mapreduce(abs, +, A) > 2.5

    A = @inferred Augmentor.uniform_field(5, 6, .5, false, false)
    @test typeof(A) <: Array{Float64}
    @test size(A) === (2, 5, 6)
    @test sum_border(A) == 0.
    @test mapreduce(abs, +, A) > 5.

    A = Augmentor.uniform_field(5, 6, scale=.5, normalize=false)
    @test typeof(A) <: Array{Float64}
    @test size(A) === (2, 5, 6)
    @test sum_border(A) == 0.
    @test mapreduce(abs, +, A) > 5.

    # TODO: test normalization
end

@testset "gaussian_field" begin
    @test_throws UndefVarError gaussian_field
    @test typeof(Augmentor.gaussian_field) <: Function

    A = @inferred Augmentor.gaussian_field(5, 6)
    @test typeof(A) <: Array{Float64}
    @test size(A) === (2, 5, 6)
    @test sum_border(A) == 0.
    @test 2.2 > mapreduce(abs, +, A) > 0.

    A = @inferred Augmentor.gaussian_field(5, 6, .5, 2, 1, false, true)
    @test typeof(A) <: Array{Float64}
    @test size(A) === (2, 5, 6)
    @test sum_border(A) == 0.
    @test mapreduce(abs, +, A) > 2.2

    A = Augmentor.gaussian_field(5, 6, scale=.5)
    @test typeof(A) <: Array{Float64}
    @test size(A) === (2, 5, 6)
    @test sum_border(A) == 0.
    @test mapreduce(abs, +, A) > 2.2

    A = @inferred Augmentor.gaussian_field(5, 6, .5, 2, 1, true, true)
    @test typeof(A) <: Array{Float64}
    @test size(A) === (2, 5, 6)
    @test sum_border(A) != 0.
    @test mapreduce(abs, +, A) > 2.2

    A = Augmentor.gaussian_field(5, 6, scale=.5, border=true)
    @test typeof(A) <: Array{Float64}
    @test size(A) === (2, 5, 6)
    @test sum_border(A) != 0.
    @test mapreduce(abs, +, A) > 2.2

    A = Augmentor.gaussian_field(5, 6, scale=.5, normalize=false)
    @test typeof(A) <: Array{Float64}
    @test size(A) === (2, 5, 6)
    @test sum_border(A) == 0.

    # TODO: test normalization
    # TODO: test iterations
end

@testset "DistortedView" begin
    @test_throws UndefVarError DistortedView
    @test Augmentor.DistortedView <: AbstractArray

    A1 = [0. 0 0; 0 -.5 0; 0 0 0]
    A2 = [0. 0 0; 0  .5 0; 0 0 0]
    A = zeros(2, 3, 3)
    A[1,:,:] = A1
    A[2,:,:] = A2
    dv = @inferred Augmentor.DistortedView(camera, A)
    @test parent(dv) === camera
    @test size(dv) == size(camera)
    @test eltype(dv) == eltype(camera)
    @test summary(dv) == "512×512 Augmentor.DistortedView(::Array{Gray{N0f8},2}, ::Array{Float64,3} as 3×3 vector field) with element type ColorTypes.Gray{FixedPointNumbers.Normed{UInt8,8}}"
    @test_reference "reference/distort_static.txt" dv

    camerao = OffsetArray(camera, (-5,-10))
    dv2 = @inferred Augmentor.DistortedView(camerao, A)
    @test size(dv2) == size(camera)
    @test eltype(dv2) == eltype(camera)
    @test summary(dv2) == "512×512 Augmentor.DistortedView(::OffsetArray{Gray{N0f8},2}, ::Array{Float64,3} as 3×3 vector field) with element type ColorTypes.Gray{FixedPointNumbers.Normed{UInt8,8}}"
    @test_reference "reference/distort_static.txt" dv2

    v = view(Augmentor.DistortedView(rand(10,10), A), 2:8, 3:10)
    @test summary(v) == "7×8 view(Augmentor.DistortedView(::Array{Float64,2}, ::Array{Float64,3} as 3×3 vector field), 2:8, 3:10) with element type Float64"
end
