struct DistortedView{T,P<:AbstractMatrix,E<:AbstractExtrapolation,G,D} <: AbstractArray{T,2}
    parent::P
    etp::E
    grid::G
    field::D

    function DistortedView(parent::AbstractMatrix{T}, grid::AbstractArray{Float64,3}) where T
        @assert size(grid,1) == 2
        etp = ImageTransformations.box_extrapolation(parent, Flat())
        field = ImageTransformations.box_extrapolation(grid, 0.0)
        new{T,typeof(parent),typeof(etp),typeof(grid),typeof(field)}(parent, etp, grid, field)
    end
end

Base.parent(A::DistortedView) = A.parent
Base.size(A::DistortedView) = map(length, indices(A.parent))

function ShowItLikeYouBuildIt.showarg(io::IO, A::DistortedView)
    print(io, typeof(A).name, '(')
    showarg(io, parent(A))
    print(io, ", ")
    showarg(io, A.grid)
    print(io, " as ", size(A.field,2), '×', size(A.field,3), " vector field")
    print(io, ')')
end

# showargs for SubArray{<:Colorant} is already implemented by ImageCore
function ShowItLikeYouBuildIt.showarg(io::IO, A::SubArray{<:Number,N,<:DistortedView}) where N
    print(io, "view(")
    showarg(io, parent(A))
    print(io, ", ")
    for (i, el) in enumerate(A.indexes)
        print(io, el)
        i < length(A.indexes) && print(io, ", ")
    end
    print(io, ')')
end

Base.summary(A::DistortedView) = summary_build(A)
Base.summary(A::SubArray{<:Number,N,<:DistortedView}) where {N} = summary_build(A)

# inline speeds up ~30%
@inline function Base.getindex(A::DistortedView, i::Int, j::Int)
    # unpack member variables
    parent = A.parent
    etp    = A.etp
    field  = A.field
    # size of the parent array
    indsy, indsx = indices(parent)
    leny,  lenx  = length(indsy), length(indsx)
    # grid size of the field field
    _, gh, gw = size(field)
    # map array indices to grid indices
    gi, gj = (i-1)/(leny-1)*(gh-1)+1, (j-1)/(lenx-1)*(gw-1)+1
    # compute parent indices offset
    @inbounds dy = field[1, gi, gj] * leny
    @inbounds dx = field[2, gi, gj] * lenx
    # compute parent indices and return value
    # Note: we subtract instead of add, because the vector field is
    #       specified in forward mode (i.e. in reference to the source
    #       pixel), while here we need to compute using backward mode
    #       (in reference to the target pixel)
    checkbounds(indsy, i)
    checkbounds(indsx, j)
    @inbounds y = indsy[i] - dy
    @inbounds x = indsx[j] - dx
    @inbounds res = etp[y, x]
    res
end
