struct ImmutablePipeline{N,T<:Tuple} <: Pipeline
    operations::T

    function ImmutablePipeline{N}(ops::NTuple{N,Operation}) where N
        new{N,typeof(ops)}(ops)
    end
end
ImmutablePipeline() = throw(MethodError(ImmutablePipeline, ()))
ImmutablePipeline(::Tuple{}) = throw(MethodError(ImmutablePipeline, ((),)))
ImmutablePipeline(ops::NTuple{N,Operation}) where {N} = ImmutablePipeline{N}(ops)
ImmutablePipeline(ops::Vararg{Operation,N}) where {N} = ImmutablePipeline{N}(ops)
(::Type{Pipeline})(ops::NTuple{N,Operation}) where {N} = ImmutablePipeline(ops)
(::Type{Pipeline})(ops::Vararg{Operation,N}) where {N} = ImmutablePipeline(ops)

@inline Base.length(p::ImmutablePipeline{N}) where {N} = N
@inline operations(p::ImmutablePipeline) = p.operations
@inline operations(tup::NTuple{N,Operation}) where {N} = tup

# Allow specifying pipelines using the "op1 |> op2 |> op3" syntax.
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
