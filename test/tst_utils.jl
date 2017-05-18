@testset "testpattern" begin
    tp = testpattern()
    @test typeof(tp) <: Matrix
    @test eltype(tp) <: RGBA
    @test size(tp) === (300,400)
    tp2 = augment(NoOp())
    @test tp == tp2
end

@testset "plain_array" begin
    A = [1 2 3; 4 5 6; 7 8 9]
    As = sparse(A)
    Ast = @SMatrix [1 2 3; 4 5 6; 7 8 9]
    @test_throws MethodError Augmentor.plain_array(As)
    @test_throws MethodError Augmentor.plain_array(Ast)
    @test @inferred(Augmentor.plain_array(A)) === A
    @test @inferred(Augmentor.plain_array(OffsetArray(A, (-2,-1)))) === A
    v = view(A, 2:3, 1:2)
    @test typeof(Augmentor.plain_array(v)) <: Array
    @test @inferred(Augmentor.plain_array(v)) == A[2:3, 1:2]
    v = view(A, IdentityRange(2:3), IdentityRange(1:2))
    @test typeof(Augmentor.plain_array(v)) <: Array
    @test @inferred(Augmentor.plain_array(v)) == A[2:3, 1:2]
    p = permuteddimsview(A, (2,1))
    @test typeof(Augmentor.plain_array(p)) <: Array
    @test @inferred(Augmentor.plain_array(p)) == A'
    p = view(permuteddimsview(A, (2,1)), IdentityRange(2:3), IdentityRange(1:2))
    @test typeof(Augmentor.plain_array(p)) <: Array
    @test @inferred(Augmentor.plain_array(p)) == A'[2:3, 1:2]
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
