@testset "testpattern" begin
    tp = testpattern()
    @test typeof(tp) <: Matrix
    @test eltype(tp) <: RGBA
    @test size(tp) === (300,400)
    tp2 = augment(NoOp())
    @test tp == tp2
end

@testset "rand_mutex" begin
    mutex = Augmentor.rand_mutex[]
    typeof(mutex) <: Threads.Mutex
    # check that its not a null pointer
    @test reinterpret(Int, mutex.handle) > 0
end

@testset "safe_rand" begin
    num = @inferred Augmentor.safe_rand()
    @test 0 <= num <= 1
    @test typeof(num) <: Float64
    num = @inferred Augmentor.safe_rand(2)
    @test all(0 .<= num .<= 1)
    @test typeof(num) <: Vector{Float64}
end

@testset "maybe_copy" begin
    A = [1 2 3; 4 5 6; 7 8 9]
    Ao = OffsetArray(A, (-2,-1))
    @test @inferred(Augmentor.maybe_copy(A)) === A
    @test @inferred(Augmentor.maybe_copy(Ao)) === Ao
    let Ast = @SMatrix [1 2 3; 4 5 6; 7 8 9]
        @test @inferred(Augmentor.maybe_copy(Ast)) === Ast
    end
    let v = view(A, 2:3, 1:2)
        @test @inferred(Augmentor.maybe_copy(v)) == A[2:3, 1:2]
        @test typeof(Augmentor.maybe_copy(v)) <: Array
    end
    let v = view(OffsetArray(A, (-2,-1)), 0:1, 0:1)
        @test @inferred(Augmentor.maybe_copy(v)) == A[2:3, 1:2]
        @test typeof(Augmentor.maybe_copy(v)) <: Array
    end
    let v = view(A, IdentityRange(2:3), IdentityRange(1:2))
        @test @inferred(Augmentor.maybe_copy(v)) == OffsetArray(A[2:3,1:2], (1, 0))
        @test typeof(Augmentor.maybe_copy(v)) <: OffsetArray
    end
    let v = ChannelView(rect)
        @test @inferred(Augmentor.maybe_copy(v)) == channelview(rect)
        @test typeof(Augmentor.maybe_copy(v)) <: Array
    end
    let p = permuteddimsview(A, (2,1))
        @test @inferred(Augmentor.maybe_copy(p)) == A'
        @test typeof(Augmentor.maybe_copy(p)) <: Array
    end
    let p = permuteddimsview(Ao, (2,1))
        @test @inferred(Augmentor.maybe_copy(p)) == Ao'
        @test typeof(Augmentor.maybe_copy(p)) <: OffsetArray
    end
    let p = view(permuteddimsview(A, (2,1)), IdentityRange(2:3), IdentityRange(1:2))
        @test @inferred(Augmentor.maybe_copy(p)) == OffsetArray(A'[2:3, 1:2],1,0)
        @test typeof(Augmentor.maybe_copy(p)) <: OffsetArray
    end
    let Aa = Augmentor.prepareaffine(A)
        @test @inferred(Augmentor.maybe_copy(Aa)) == OffsetArray(A, (0,0))
        @test typeof(Augmentor.maybe_copy(Aa)) <: OffsetArray
    end
    let Ar = reshape(view(A,:,:),1,3,3)
        @test @inferred(Augmentor.maybe_copy(Ar)) == reshape(A,1,3,3)
        @test typeof(Augmentor.maybe_copy(Ar)) <: Array{Int,3}
    end
    let Ar = reshape(view(Ao,:,:),1,3,3)
        @test @inferred(Augmentor.maybe_copy(Ar)) == reshape(A,1,3,3)
        @test typeof(Augmentor.maybe_copy(Ar)) <: Array{Int,3}
    end
end

@testset "plain_array" begin
    A = [1 2 3; 4 5 6; 7 8 9]
    @test @inferred(Augmentor.plain_array(A)) === A
    @test @inferred(Augmentor.plain_array(OffsetArray(A, (-2,-1)))) === A
    # Sparse arrays for now undefined
    #let As = sparse(A)
    #    @test @inferred(Augmentor.plain_array(As)) == A
    #    @test typeof(Augmentor.plain_array(As)) <: Array
    #    Ar = reshape(As, 3, 3, 1)
    #    @test typeof(Ar) <: Base.ReshapedArray
    #    @test @inferred(Augmentor.plain_array(Ar)) == reshape(A,3,3,1)
    #    @test typeof(Augmentor.plain_array(Ar)) <: Array
    #end
    let Ast = @SMatrix [1 2 3; 4 5 6; 7 8 9]
        @test @inferred(Augmentor.plain_array(Ast)) === Ast
    end
    let v = view(A, 2:3, 1:2)
        @test @inferred(Augmentor.plain_array(v)) == A[2:3, 1:2]
        @test typeof(Augmentor.plain_array(v)) <: Array
    end
    let v = view(OffsetArray(A, (-2,-1)), 0:1, 0:1)
        @test @inferred(Augmentor.plain_array(v)) == A[2:3, 1:2]
        @test typeof(Augmentor.plain_array(v)) <: Array
    end
    let v = view(A, IdentityRange(2:3), IdentityRange(1:2))
        @test @inferred(Augmentor.plain_array(v)) == A[2:3, 1:2]
        @test typeof(Augmentor.plain_array(v)) <: Array
    end
    let v = ChannelView(rect)
        @test @inferred(Augmentor.plain_array(v)) == channelview(rect)
        @test typeof(Augmentor.plain_array(v)) <: Array
    end
    let p = permuteddimsview(A, (2,1))
        @test @inferred(Augmentor.plain_array(p)) == A'
        @test typeof(Augmentor.plain_array(p)) <: Array
    end
    let p = view(permuteddimsview(A, (2,1)), IdentityRange(2:3), IdentityRange(1:2))
        @test @inferred(Augmentor.plain_array(p)) == A'[2:3, 1:2]
        @test typeof(Augmentor.plain_array(p)) <: Array
    end
    let Aa = Augmentor.prepareaffine(A)
        @test @inferred(Augmentor.plain_array(Aa)) == A
        @test typeof(Augmentor.plain_array(Aa)) <: Array
    end
    let Ar = reshape(view(A,:,:),1,3,3)
        @test @inferred(Augmentor.plain_array(Ar)) == reshape(A,1,3,3)
        @test typeof(Augmentor.plain_array(Ar)) <: Array{Int,3}
    end
end

@testset "plain_indices" begin
    A = [1 2 3; 4 5 6; 7 8 9]
    @test @inferred(Augmentor.plain_indices(A)) === A
    @test @inferred(Augmentor.plain_indices(OffsetArray(A, (-2,-1)))) === A
    let v = view(A, 2:3, 1:2)
        @test @inferred(Augmentor.plain_indices(v)) === v
    end
    let v = view(OffsetArray(A, (-2,-1)), 0:1, 0:1)
        @test @inferred(Augmentor.plain_indices(v)) === v
    end
    let v = view(A, IdentityRange(2:3), IdentityRange(1:2))
        @test @inferred(Augmentor.plain_indices(v)) === view(A, 2:3, 1:2)
    end
    let v = ChannelView(rect)
        @test @inferred(Augmentor.plain_indices(v)) === v
    end
    let p = permuteddimsview(A, (2,1))
        @test @inferred(Augmentor.plain_indices(p)) === p
    end
    let p = view(permuteddimsview(A, (2,1)), IdentityRange(2:3), IdentityRange(1:2))
        @test @inferred(Augmentor.plain_indices(p)) === view(parent(p), 2:3, 1:2)
    end
    let Aa = Augmentor.prepareaffine(A)
        @test @inferred(Augmentor.plain_indices(Aa)) === view(Aa, indices(Aa)...)
    end
    let Ar = reshape(view(A,:,:),1,3,3)
        @test @inferred(Augmentor.plain_indices(Ar)) === Ar
    end
end

@testset "match_idx" begin
    A = [1 2 3; 4 5 6; 7 8 9]
    @test @inferred(Augmentor.match_idx(A, indices(A))) === A
    let img = @inferred Augmentor.match_idx(A, (2:4, 2:4))
        @test indices(img) === (2:4, 2:4)
        @test typeof(img) <: OffsetArray
    end
    let B = view(A,1:3,1:3)
        @test @inferred(Augmentor.match_idx(B, indices(B))) === B
    end
    let B = view(A,1:3,1:3)
        img = @inferred(Augmentor.match_idx(B, B.indexes))
        @test indices(img) === (1:3, 1:3)
        @test typeof(img) <: OffsetArray
    end
    let img = @inferred Augmentor.match_idx(view(A,1:3,1:3), (2:4,2:4))
        @test indices(img) === (2:4, 2:4)
        @test typeof(img) <: OffsetArray
    end
    let C = Augmentor.prepareaffine(A)
        @test @inferred(Augmentor.match_idx(C, (2:4, 2:4))) === C
    end
end

@testset "direct_view" begin
    A = [1 2 3; 4 5 6; 7 8 9]
    Av = view(A, IdentityRange(2:3), IdentityRange(1:2))
    As = view(A, 3:-1:2, 1:1:2)
    @test_throws MethodError Augmentor.indirect_indices((), ())
    @test_throws MethodError Augmentor.direct_indices((), ())
    @test_throws MethodError Augmentor.direct_view(A, ())
    @test @inferred(Augmentor.direct_view(A, (2:3,1:2))) === Av
    @test @inferred(Augmentor.indirect_view(A, (2:3,1:2))) === Av
    @test @inferred(Augmentor.direct_view(A, (IdentityRange(2:3),IdentityRange(1:2)))) === Av
    @test @inferred(Augmentor.indirect_view(A, (IdentityRange(2:3),IdentityRange(1:2)))) === Av
    @test @inferred(Augmentor.direct_view(A, (3:-1:2,1:1:2))) === As
    @test @inferred(Augmentor.indirect_view(A, (3:-1:2,1:1:2))) === As
    @test @inferred(Augmentor.direct_view(Av, (3:3,1:2))) === view(Av,3:3,1:2)
    @test @inferred(Augmentor.indirect_view(Av, (2:2,1:2))) === view(Av,3:3,1:2)
    @test @inferred(Augmentor.direct_view(Av, (IdentityRange(3:3),IdentityRange(1:2)))) === view(Av,3:3,1:2)
    @test @inferred(Augmentor.indirect_view(Av, (IdentityRange(2:2),IdentityRange(1:2)))) === view(Av,3:3,1:2)
    @test_throws MethodError Augmentor.direct_view(Av, (3:-1:2,2:-1:1))
    @test @inferred(Augmentor.indirect_view(Av, (2:-1:1,2:-1:1))) === view(A,3:-1:2,2:-1:1)
end

@testset "vectorize" begin
    @test @inferred(Augmentor.vectorize(2)) === 2:2
    @test @inferred(Augmentor.vectorize(2.3)) === 2.3:2.3
    @test @inferred(Augmentor.vectorize(3:4)) === 3:4
    @test @inferred(Augmentor.vectorize(3:1:4)) === 3:1:4
    @test @inferred(Augmentor.vectorize(3.0:4)) === 3.0:4
    @test @inferred(Augmentor.vectorize(3.0:1:4)) === 3.0:1:4
    @test @inferred(Augmentor.vectorize(Base.OneTo(4))) === Base.OneTo(4)
end

@testset "round_if_float" begin
    @test @inferred(Augmentor.round_if_float(3,2)) === 3
    @test @inferred(Augmentor.round_if_float(3.1111,2)) === 3.11
    @test @inferred(Augmentor.round_if_float((3,3.1111),2)) === (3,3.11)
end

@testset "unionrange" begin
    @test_throws MethodError Augmentor.unionrange(1:1:2, 4:5)
    @test @inferred(Augmentor.unionrange(1:5, 2:6)) === 1:6
    @test @inferred(Augmentor.unionrange(2:6, 1:5)) === 1:6
    @test @inferred(Augmentor.unionrange(1:2, 4:5)) === 1:5
    @test @inferred(Augmentor.unionrange(Base.OneTo(2), 4:5)) === 1:5
    @test @inferred(Augmentor.unionrange(1:6, 2:3)) === 1:6
    @test @inferred(Augmentor.unionrange(2:3, 1:6)) === 1:6
end

@testset "_2dborder!" begin
    A = rand(2, 5, 6)
    @test @inferred(Augmentor._2dborder!(A, 0.)) === A
    s = 0.
    ndim, h, w = size(A)
    for i = 1:h, j = 1:w
        if i == 1 || j == 1 || i == h || j == w
            for d = 1:ndim
                s += abs(A[d, i, j])
            end
        end
    end
    @test s == 0.
end
