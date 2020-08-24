struct DistortedView{T,P<:AbstractMatrix,E<:AbstractExtrapolation,G,D} <: AbstractArray{T,2}
    parent::P
    etp::E
    grid::G
    field::D

    function DistortedView(parent::AbstractMatrix{T}, grid::AbstractArray{Float64,3}) where T
        @assert size(grid,1) == 2
        # to compare two DistortedViews, their `axes` should be the same
        parent = plain_axes(parent)
        etp = ImageTransformations.box_extrapolation(parent, Flat())
        field = ImageTransformations.box_extrapolation(grid, 0.0)
        new{T,typeof(parent),typeof(etp),typeof(grid),typeof(field)}(parent, etp, grid, field)
    end
end

Base.parent(A::DistortedView) = A.parent
Base.size(A::DistortedView) = map(length, axes(A))
Base.axes(A::DistortedView) = axes(A.parent)

function Base.showarg(io::IO, A::DistortedView, toplevel)
    print(io, typeof(A).name.name, '(')
    Base.showarg(io, parent(A), false)
    print(io, ", ")
    Base.showarg(io, A.grid, false)
    print(io, " as ", size(A.field,2), '×', size(A.field,3), " vector field")
    print(io, ')')
    toplevel && print(io, " with eltype ", eltype(A))
end

# inline speeds up ~30%
@inline function Base.getindex(A::DistortedView, i::Int, j::Int)
    # unpack member variables
    parent = A.parent
    etp    = A.etp
    field  = A.field
    # size of the parent array
    indsy, indsx = axes(parent)
    leny,  lenx  = length(indsy), length(indsx)
    # grid size of the field
    _, gh, gw = size(field)
    # map array indices to grid indices
    gi, gj = (i-1)/(leny-1)*(gh-1)+1, (j-1)/(lenx-1)*(gw-1)+1
    # compute parent indices offset
    @inbounds dy = field(1, gi, gj) * leny
    @inbounds dx = field(2, gi, gj) * lenx
    # compute parent indices and return value
    # Note: we subtract instead of add, because the vector field is
    #       specified in forward mode (i.e. in reference to the source
    #       pixel), while here we need to compute using backward mode
    #       (in reference to the target pixel)
    checkbounds(indsy, i)
    checkbounds(indsx, j)
    @inbounds y = indsy[i] - dy
    @inbounds x = indsx[j] - dx
    @inbounds res = etp(y, x)
    res
end
