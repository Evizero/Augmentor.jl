"""
    Either <: Augmentor.ImageOperation

Description
--------------

Allows for choosing between different `Augmentor.Operations` at
random when applied. This is particularly useful if one for
example wants to first either rotate the image 90 degree
clockwise or anticlockwise (but never both) and then apply some
other operation(s) afterwards.

When compiling a pipeline, `Either` will analyze the provided
`operations` in order to identify the most preferred way to apply
the individual operation when sampled, that is supported by all
given `operations`. This way the output of applying `Either` will
be inferable and the whole pipeline will remain type-stable, even
though randomness is involved.

By default each specified image operation has the same
probability of occurrence. This default behaviour can be
overwritten by specifying the `chance` manually.

Usage
--------------

    Either(operations, [chances])

    Either(operations...; [chances])

    Either(pairs...)

    *(operations...)

    *(pairs...)

Arguments
--------------

- **`operations`** : `NTuple` or `Vararg` of `Augmentor.ImageOperation`
    that denote the possible choices to sample from when applied.

- **`chances`** : Optional. Denotes the relative chances for an
    operation to be sampled. Has to contain the same number of
    elements as `operations`. Either an `NTuple` of numbers if
    specified as positional argument, or alternatively a
    `AbstractVector` of numbers if specified as a keyword
    argument. If omitted every operation will have equal
    probability of occurring.

- **`pairs`** : `Vararg` of `Pair{<:Real,<:Augmentor.ImageOperation}`.
    A compact way to specify an operation and its chance of
    occurring together.

Examples
--------------

```julia
using Augmentor
img = testpattern()

# all three operations have equal chance of occuring
augment(img, Either(FlipX(), FlipY(), NoOp()))
augment(img, FlipX() * FlipY() * NoOp())

# NoOp is twice as likely as either FlipX or FlipY
augment(img, Either(1=>FlipX(), 1=>FlipY(), 2=>NoOp()))
augment(img, Either(FlipX(), FlipY(), NoOp(), chances=[1,1,2]))
augment(img, Either((FlipX(), FlipY(), NoOp()), (1,1,2)))
augment(img, (1=>FlipX()) * (1=>FlipY()) * (2=>NoOp()))
```

see also
--------------

[`augment`](@ref)
"""
immutable Either{N,T<:Tuple} <: ImageOperation
    operations::T
    chances::SVector{N,Float64}
    cum_chances::SVector{N,Float64}

    function (::Type{Either}){N,T}(operations::NTuple{N,ImageOperation}, chances::SVector{N,T})
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

function Either{N}(operations::NTuple{N,ImageOperation}, chances::NTuple{N,Real} = map(op -> 1/length(operations), operations))
    Either(operations, SVector{N}(chances))
end

function Either{N}(operations::Vararg{ImageOperation,N}; chances = map(op -> 1/length(operations), operations))
    Either(operations, SVector{N}(map(Float64, chances)))
end

function Either{N}(operations::Vararg{Pair,N})
    Either(map(last, operations), map(first, operations))
end

function Either(op::ImageOperation, p::Real = .5)
    0 <= p <= 1. || throw(ArgumentError("The propability \"p\" has to be in the interval [0, 1]"))
    p1 = Float64(p)
    p2 = 1 - p1
    Either((op, NoOp()), (p1, p2))
end


Base.:*{T<:Number,O<:Operation}(op1::Pair{T,O}, ops::Pair...) =
    Either(op1, ops...)
Base.:*(op1::Operation, ops::Operation...) = Either((op1, ops...))

@inline supports_permute{N,T}(::Type{Either{N,T}}) = all(map(supports_permute, T.types))
@inline supports_view{N,T}(::Type{Either{N,T}}) = all(map(supports_view, T.types))
@inline supports_stepview{N,T}(::Type{Either{N,T}}) = all(map(supports_stepview, T.types))
# "Either" only supports affine if all its elements are affine
@inline isaffine{N,T}(::Type{Either{N,T}}) = all(map(isaffine, T.types))

# choose lazy strategy based on shared qualities of elements
@inline isaffine{T,N,P<:InvWarpedView,I,L}(::Type{SubArray{T,N,P,I,L}}) = true
@inline isaffine{T<:InvWarpedView}(::Type{T}) = true
@generated function applylazy(op::Either, img)
    if isaffine(img) && supports_affine(op)
        :(applyaffine(op, img))
    elseif supports_view(op)
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

# TODO: implement method for n-dim arrays
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

function showconstruction(io::IO, op::Either)
    chances_float = map(c->round(c, 3), op.chances)
    if all(x->x≈chances_float[1], chances_float)
        for (i, op_i) in enumerate(op.operations)
            showconstruction(io, op_i)
            i < length(op.operations) && print(io, " * ")
        end
    else
        for (i, (op_i, p_i)) in enumerate(zip(op.operations, chances_float))
            print(io, '(', p_i, "=>")
            showconstruction(io, op_i)
            print(io, ')')
            i < length(op.operations) && print(io, " * ")
        end
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
        print(io, typeof(op).name, " (1 out of ", length(op.operations), " operation(s)):")
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
