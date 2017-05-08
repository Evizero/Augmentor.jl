immutable Either{N,T<:Tuple} <: Operation
    operations::T
    chances::SVector{N,Float64}
    cum_chances::SVector{N,Float64}

    function (::Type{Either}){N,T}(operations::Pipeline{N}, chances::SVector{N,T})
        all(c->c>=0, chances) || throw(ArgumentError("All provided \"chances\" must be positive"))
        length(operations) > 0 || throw(ArgumentError("Must provide at least one operation in the constructor of \"Either\""))
        sum_chances = sum(chances)
        sum_chances > 0 || throw(ArgumentError("The sum of all provided \"chances\" must be strictly positive"))
        norm_chances = map(x -> Float64(x/sum_chances), chances)
        cum_chances = SVector(cumsum(norm_chances))
        new{N,typeof(operations)}(operations, norm_chances, cum_chances)
    end
end

Either() = throw(ArgumentError("Must provide at least one operation in the constructor of \"Either\""))

function Either{N}(operations::Pipeline{N}, chances::NTuple{N,Real} = map(op -> 1/length(operations), operations))
    Either(operations, SVector{N}(chances))
end

function Either{N}(operations::Vararg{Operation,N}; chances = map(op -> 1/length(operations), operations))
    Either(operations, SVector{N}(map(Float64, chances)))
end

function Either{N}(operations::Vararg{Pair,N})
    Either(map(last, operations), map(first, operations))
end

function Either(op::Operation, p::Real = .5)
    0 <= p <= 1. || throw(ArgumentError("The propability \"p\" has to be in the interval [0, 1]"))
    p1 = Float64(p)
    p2 = 1 - p1
    Either((op, NoOp()), (p1, p2))
end

# "Either" is only lazy if all its elements are affine
Base.@pure supports_permute{N,T}(::Type{Either{N,T}}) = all(map(supports_permute, T.types))
Base.@pure supports_view{N,T}(::Type{Either{N,T}}) = all(map(supports_view, T.types))
Base.@pure supports_stepview{N,T}(::Type{Either{N,T}}) = all(map(supports_stepview, T.types))
Base.@pure isaffine{N,T}(::Type{Either{N,T}}) = all(map(isaffine, T.types))

# choose lazy strategy based on shared qualities of elements
@generated function applylazy(op::Either, img)
    if supports_view(op)
        :(applyview(op, prepareview(img)))
    elseif supports_stepview(op)
        :(applystepview(op, preparestepview(img)))
    elseif supports_permute(op)
        :(applypermute(op, preparepermute(img)))
    elseif supports_affine(op)
        :(applyaffine(op, prepareaffine(img)))
    else
        :(throw(MethodError(applylazy, (op, img))))
    end
end

function toaffine(op::Either, img::AbstractMatrix)
    supports_affine(typeof(op)) || throw(MethodError(toaffine, (op, img)))
    p = rand()
    for (i, p_i) in enumerate(op.cum_chances)
        if p <= p_i
            tfm = toaffine(op.operations[i], img)
            return AffineMap(SMatrix(tfm.m), SVector(tfm.v))::AffineMap{SMatrix{2,2,Float64,4},SVector{2,Float64}}
        end
    end
    error("unreachable code reached")
end

function applyaffine(op::Either, img)
    invwarpedview(img, toaffine(op, img))
end

for KIND in (:eager, :permute, :view, :stepview)
    APP = Symbol(:apply, KIND)
    SUP = Symbol(:supports_, KIND)
    @eval function ($APP)(op::Either, img)
        ($SUP)(typeof(op)) || throw(MethodError($APP, (op, img)))
        p = rand()
        for (i, p_i) in enumerate(op.cum_chances)
            if p <= p_i
                return ($APP)(op.operations[i], img)
            end
        end
        error("unreachable code reached")
    end
end

function Base.show(io::IO, op::Either)
    if get(io, :compact, false)
        print(io, "Either:")
        for (op_i, p_i) in zip(op.operations, op.chances)
            print(io, " (", round(Int, p_i*100), "%) ")
            Base.showcompact(io, op_i)
            print(io, '.')
        end
    else
        print(io, "Augmentor.Either (1 out of ", length(op.operations), " operation(s)):")
        percent_int   = map(c->round(Int, c*100), op.chances)
        percent_float = map(c->round(c*100, 1), op.chances)
        percent = if any(i != f for (i,f) in zip(percent_int,percent_float))
            percent_float
        else
            percent_int
        end
        k = maximum(length(string(c)) for c in percent)
        for (op_i, p_i) in zip(op.operations, percent)
            println(io)
            print(io, "  - ", lpad(string(p_i), k, " "), "% chance to: ")
            Base.showcompact(io, op_i)
        end
    end
end
