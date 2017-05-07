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

@testset "identity_view" begin
    A = [1 2 3; 4 5 6; 7 8 9]
    Av = view(A, IdentityRange(2:3), IdentityRange(1:2))
    As = view(A, 3:-1:2, 1:1:2)
    @test @inferred(Augmentor.identity_view(A, (2:3,1:2))) === Av
    @test @inferred(Augmentor.identity_view(A, (IdentityRange(2:3),IdentityRange(1:2)))) === Av
    @test @inferred(Augmentor.identity_view(A, (3:-1:2,1:1:2))) === As

    @test @inferred(Augmentor.identity_view(Av, (2:2,1:2))) === view(Av,3:3,1:2)
    @test @inferred(Augmentor.identity_view(Av, (IdentityRange(3:3),IdentityRange(1:2)))) === view(Av,3:3,1:2)
    @test @inferred(Augmentor.identity_view(Av, (2:-1:1,2:-1:1))) === view(A,3:-1:2,2:-1:1)
end
