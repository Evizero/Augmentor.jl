# test not exported
@test_throws UndefVarError Pipeline
@test_throws UndefVarError AbstractPipeline
@test_throws UndefVarError ImmutablePipeline
@test Augmentor.AbstractPipeline <: Any
@test Augmentor.Pipeline <: Augmentor.AbstractPipeline
@test Augmentor.ImmutablePipeline <: Augmentor.Pipeline

@test typeof((FlipX(),FlipY())) <: Augmentor.AbstractPipeline
@test Augmentor.operations((FlipX(),FlipY())) === (FlipX(),FlipY())

@testset "ImmutablePipeline" begin
    @test_throws MethodError Augmentor.ImmutablePipeline()
    @test_throws MethodError Augmentor.ImmutablePipeline(())
    @test_throws MethodError Augmentor.ImmutablePipeline(1)
    @test_throws MethodError Augmentor.ImmutablePipeline((1,))
    @test_throws MethodError Augmentor.ImmutablePipeline{1}((1,))
    @test_throws MethodError Augmentor.ImmutablePipeline{2}((FlipX(),))
    @test_throws MethodError Augmentor.ImmutablePipeline{1}(FlipX())

    @test @inferred(Augmentor.ImmutablePipeline(FlipX())) === @inferred(Augmentor.ImmutablePipeline{1}((FlipX(),)))

    p = @inferred Augmentor.ImmutablePipeline(FlipX())
    @test p === @inferred(Augmentor.ImmutablePipeline((FlipX(),)))
    @test typeof(p) <: Augmentor.ImmutablePipeline{1}
    @test @inferred(length(p)) === 1
    @test @inferred(Augmentor.operations(p)) === (FlipX(),)

    p = @inferred Augmentor.ImmutablePipeline(FlipX(), FlipY())
    @test p === @inferred(Augmentor.ImmutablePipeline((FlipX(),FlipY())))
    @test typeof(p) <: Augmentor.ImmutablePipeline{2}
    @test @inferred(length(p)) === 2
    @test @inferred(Augmentor.operations(p)) === (FlipX(),FlipY())

    p = @inferred Augmentor.ImmutablePipeline(FlipX(), FlipY(), Rotate90())
    @test p === @inferred(Augmentor.ImmutablePipeline((FlipX(),FlipY(),Rotate90())))
    @test typeof(p) <: Augmentor.ImmutablePipeline{3}
    @test @inferred(length(p)) === 3
    @test @inferred(Augmentor.operations(p)) === (FlipX(),FlipY(),Rotate90())
end

@testset "ImmutablePipeline with |>" begin
    buf = rand(2,2)

    p = @inferred(FlipX() |> FlipY())
    @test p === Augmentor.ImmutablePipeline(FlipX(), FlipY())

    p = @inferred(FlipX() |> buf |> FlipY())
    @test p === Augmentor.ImmutablePipeline(FlipX(), CacheImage(buf), FlipY())

    p = @inferred(FlipX() |> CacheImage(buf) |> FlipY())
    @test p === Augmentor.ImmutablePipeline(FlipX(), CacheImage(buf), FlipY())

    p = @inferred(FlipX() |> CacheImage() |> FlipY())
    @test p === Augmentor.ImmutablePipeline(FlipX(), CacheImage(), FlipY())

    p = @inferred(FlipX() |> FlipY() |> buf)
    @test p === Augmentor.ImmutablePipeline(FlipX(), FlipY(), CacheImage(buf))

    p = @inferred(FlipX() |> NoOp() |> FlipY())
    @test p === Augmentor.ImmutablePipeline(FlipX(), NoOp(), FlipY())

    p = @inferred((FlipX() |> NoOp()) |> FlipY())
    @test p === Augmentor.ImmutablePipeline(FlipX(), NoOp(), FlipY())

    p = @inferred(FlipX() |> (NoOp() |> FlipY()))
    @test p === Augmentor.ImmutablePipeline(FlipX(), NoOp(), FlipY())

    p = @inferred(FlipX() |> NoOp() |> FlipY() |> Rotate90())
    @test p === Augmentor.ImmutablePipeline(FlipX(), NoOp(), FlipY(), Rotate90())

    p = @inferred((FlipX() |> NoOp()) |> (FlipY() |> Rotate90()))
    @test p === Augmentor.ImmutablePipeline(FlipX(), NoOp(), FlipY(), Rotate90())

    p = FlipX() * FlipY() |> Rotate90() * Rotate270()
    @test p == Augmentor.ImmutablePipeline(Either(FlipX(),FlipY()), Either(Rotate90(),Rotate270()))

    p = NoOp() * FlipX() * FlipY() |> Rotate90() * Rotate270()
    @test p == Augmentor.ImmutablePipeline(Either(NoOp(),FlipX(),FlipY()), Either(Rotate90(),Rotate270()))
end

@testset "Pipeline constructor" begin
    @test_throws MethodError Augmentor.Pipeline()
    @test_throws MethodError Augmentor.Pipeline(())
    @test_throws MethodError Augmentor.Pipeline(1)
    @test_throws MethodError Augmentor.Pipeline((1,))

    p = @inferred Augmentor.Pipeline(FlipX())
    @test typeof(p) <: Augmentor.ImmutablePipeline
    @test p == Augmentor.ImmutablePipeline(FlipX())

    p = @inferred Augmentor.Pipeline((FlipX(),))
    @test typeof(p) <: Augmentor.ImmutablePipeline
    @test p == Augmentor.ImmutablePipeline(FlipX())

    p = @inferred Augmentor.Pipeline(FlipX(), FlipY())
    @test typeof(p) <: Augmentor.ImmutablePipeline
    @test p == Augmentor.ImmutablePipeline(FlipX(),FlipY())

    p = @inferred Augmentor.Pipeline((FlipX(), FlipY()))
    @test typeof(p) <: Augmentor.ImmutablePipeline
    @test p == Augmentor.ImmutablePipeline(FlipX(),FlipY())
end

@test str_show(Augmentor.ImmutablePipeline(Rotate90(),Rotate270(),NoOp())) == """
3-step Augmentor.ImmutablePipeline:
 1.) Rotate 90 degree
 2.) Rotate 270 degree
 3.) No operation"""
 @test str_showcompact(Augmentor.ImmutablePipeline(Rotate90(.2),Rotate270(),NoOp())) == "(0.2=>Rotate90()) * (0.8=>NoOp()) |> Rotate270() |> NoOp()"
@test str_showcompact(Augmentor.ImmutablePipeline(Rotate90())) == "Rotate90()"
