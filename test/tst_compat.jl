# TODO: remove this testset when we dicide to drop 1.0 compatibility
if VERSION < v"1.3"
    @testset "safe_rand" begin
        mutex = Augmentor.rand_mutex[]
        typeof(mutex) <: Threads.Mutex
        # check that its not a null pointer
        @test reinterpret(Int, mutex.handle) > 0

        num = @inferred Augmentor.safe_rand()
        @test 0 <= num <= 1
        @test typeof(num) <: Float64
        num = @inferred Augmentor.safe_rand(2)
        @test all(0 .<= num .<= 1)
        @test typeof(num) <: Vector{Float64}
    end
end