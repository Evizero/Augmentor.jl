immutable ImmutablePipeline{N,T<:Tuple} <: Pipeline
    operations::T

    function (::Type{ImmutablePipeline{N}}){N}(ops::NTuple{N,Operation})
        new{N,typeof(ops)}(ops)
    end
end
ImmutablePipeline() = throw(MethodError(ImmutablePipeline, ()))
ImmutablePipeline(::Tuple{}) = throw(MethodError(ImmutablePipeline, ((),)))
ImmutablePipeline{N}(ops::NTuple{N,Operation}) = ImmutablePipeline{N}(ops)
ImmutablePipeline{N}(ops::Vararg{Operation,N}) = ImmutablePipeline{N}(ops)
(::Type{Pipeline}){N}(ops::NTuple{N,Operation}) = ImmutablePipeline(ops)
(::Type{Pipeline}){N}(ops::Vararg{Operation,N}) = ImmutablePipeline(ops)

@inline Base.length{N}(p::ImmutablePipeline{N}) = N
@inline operations(p::ImmutablePipeline) = p.operations
@inline operations{N}(tup::NTuple{N,Operation}) = tup

Base.:(|>)(op1::Operation, op2::Operation) =
    ImmutablePipeline(op1, op2)
Base.:(|>)(p1::ImmutablePipeline, op2::Operation) =
    ImmutablePipeline(operations(p1)..., op2)
Base.:(|>)(op1::Operation, p2::ImmutablePipeline) =
    ImmutablePipeline(op1, operations(p2)...)
Base.:(|>)(p1::ImmutablePipeline, p2::ImmutablePipeline) =
    ImmutablePipeline(operations(p1)..., operations(p2)...)
Base.:(|>)(op1::Operation, buffer::AbstractArray) =
    ImmutablePipeline(op1, CacheImage(buffer))
Base.:(|>)(p1::ImmutablePipeline, buffer::AbstractArray) =
    ImmutablePipeline(operations(p1)..., CacheImage(buffer))

function Base.show(io::IO, pipeline::Pipeline)
    n = length(pipeline)
    ops = operations(pipeline)
    if get(io, :compact, false)
        for (i, op) in enumerate(ops)
            showconstruction(io, op)
            i < n && print(io, " |> ")
        end
    else
        k = length("$n")
        print(io, "$n-step $(typeof(pipeline).name):")
        for (i, op) in enumerate(ops)
            println(io)
            print(io, lpad(string(i), k+1, " "), ".) ")
            Base.showcompact(io, op)
        end
    end
end
