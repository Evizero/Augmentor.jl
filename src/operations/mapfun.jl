struct MapFun{T} <: Operation
    fun::T
end

@inline supports_lazy(::Type{<:MapFun}) = true

function applyeager(op::MapFun{T}, img::AbstractArray) where T
    map(op.fun, img)
end

function applylazy(op::MapFun{T}, img::AbstractArray) where T
    mappedarray(op.fun, img)
end

function showconstruction(io::IO, op::MapFun)
    print(io, typeof(op).name.name, '(', op.fun, ')')
end

function Base.show(io::IO, op::MapFun)
    if get(io, :compact, false)
        print(io, "Map function \"", op.fun, "\" over image")
    else
        print(io, "Augmentor.")
        showconstruction(io, op)
    end
end
