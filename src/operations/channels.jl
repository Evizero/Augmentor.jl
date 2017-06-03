immutable SplitChannels <: Operation end

@inline supports_eager(::Type{SplitChannels}) = false
@inline supports_lazy(::Type{SplitChannels}) = true

applylazy(op::SplitChannels, img) = channelview(img)

# --------------------------------------------------------------------

immutable CombineChannels{T<:Colorant} <: Operation
    colortype::Type{T}
end

@inline supports_eager{T<:CombineChannels}(::Type{T}) = false
@inline supports_lazy{T<:CombineChannels}(::Type{T}) = true

applylazy(op::CombineChannels, img) = colorview(op.colortype, img)

# --------------------------------------------------------------------

immutable PermuteDims{N,perm,iperm} <: Operation end
PermuteDims{N}(perm::Vararg{Int,N}) = PermuteDims{N,perm,invperm(perm)}()

@inline supports_eager{T<:PermuteDims}(::Type{T}) = true
@inline supports_lazy{T<:PermuteDims}(::Type{T}) = true

applyeager{N,perm}(op::PermuteDims{N,perm}, img) = permutedims(img, perm)
function applylazy{T,N,perm,iperm}(op::PermuteDims{N,perm,iperm}, img::AbstractArray{T,N})
    PermutedDimsArray{T,N,perm,iperm,typeof(img)}(img)
end

# --------------------------------------------------------------------

immutable Reshape{T<:Tuple{Vararg{Int}}} <: Operation
    dims::T
end
Reshape(dims::Int...) = Reshape(dims)

@inline supports_eager{T<:Reshape}(::Type{T}) = false
@inline supports_lazy{T<:Reshape}(::Type{T}) = true

applylazy(op::Reshape, img) = reshape(img, op.dims)
