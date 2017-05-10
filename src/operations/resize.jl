immutable Resize{N} <: Operation
    size::NTuple{N,Int}

    function (::Type{Resize{N}}){N}(size::NTuple{N,Int})
        all(s->s>0, size) || throw(ArgumentError("Specified sizes must be strictly greater than 0. Actual: $size"))
        new{N}(size)
    end
end
Resize(::Tuple{}) = throw(MethodError(Resize, ((),)))
Resize(; width=64, height=64) = Resize((height,width))
Resize(size::Vararg{Int}) = Resize(size)
Resize{N}(size::NTuple{N}) = Resize{N}(size)

applyeager(op::Resize, img) = plain_array(imresize(img, op.size))

function Base.show{N}(io::IO, op::Resize{N})
    if get(io, :compact, false)
        if N == 2
            print(io, "Resize to $(op.size[1])×$(op.size[2])")
        else
            print(io, "Resize to $(op.size)")
        end
    else
        print(io, "$(typeof(op))($(op.size))")
    end
end
