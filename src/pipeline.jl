function Base.show(io::IO, pipeline::Pipeline{0})
    print(io, "()")
end

function Base.show{N}(io::IO, pipeline::Pipeline{N})
    n = length(pipeline)
    if get(io, :compact, false)
        print(io, '(')
        for (i, op) in enumerate(pipeline)
            Base.showcompact(io, op)
            i < n && print(io, ", ")
        end
        print(io, ')')
    else
        k = length("$(length(pipeline))")
        print(io, "$n-step Augmentor.Pipeline:")
        for (i, op) in enumerate(pipeline)
            println(io)
            print(io, lpad(string(i), k+1, " "), ".) ")
            Base.showcompact(io, op)
        end
    end
end
