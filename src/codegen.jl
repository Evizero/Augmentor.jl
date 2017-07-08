"""
    seek_connected(f, N::Int, head::DataType, tail::Tuple) -> (N, remainder)

Recursively scan a tuple of `DataType` (split into its `head` and
`tail`) to compute the length `N` of the uninterrupted sequence
of adjacent operations where the predicate `f` is true.
Additionally the `remainder` of the tuple (without that sequence)
is also returned.
"""
@inline function seek_connected(f, N::Int, head::Type{<:Operation}, tail::Tuple)
    if f(head)
        seek_connected(f, N+1, first(tail), Base.tail(tail))
    else
        N, (head, tail...)
    end
end

@inline function seek_connected(f, N::Int, head::Type{<:Operation}, tail::Tuple{})
    if f(head)
        N+1, ()
    else
        N, (head,)
    end
end

# --------------------------------------------------------------------

@inline supports_lazy(head::Type{<:Operation}, tail::Tuple{}) = false
@inline supports_lazy(head::Type{<:Operation}, tail::Tuple) =
    supports_lazy(head) && supports_lazy(first(tail))
@inline uses_affinemap(head::Type{<:Operation}, tail::Tuple{}) = false
@inline uses_affinemap(head::Type{<:Operation}, tail::Tuple) =
    uses_affinemap(head) && uses_affinemap(first(tail))

# --------------------------------------------------------------------

function augment_impl(var_offset::Int, op_offset::Int, pipeline::Tuple, args...)
    augment_impl(var_offset, op_offset, first(pipeline), Base.tail(pipeline), args...)
end

function augment_impl(var_offset::Int, op_offset::Int, pipeline::Tuple{}, args...)
    :($(Symbol(:img_, var_offset)))
end

function augment_impl(var_offset::Int, op_offset::Int, head::DataType, tail::NTuple{N,DataType}, avoid_eager = false) where N
    var_in  = Symbol(:img_, var_offset)
    var_out = Symbol(:img_, var_offset+1)
    if supports_lazy(head, tail)
        # If reached there are at least two adjacent lazy operations
        num_affine, after_affine = uses_affinemap(head, tail) ? seek_connected(uses_affinemap, 0, head, tail) : (0, nothing)
        num_special, _ = seek_connected(x->(supports_permute(x)||supports_view(x)||supports_stepview(x)), 0, head, tail)
        num_lazy, after_lazy = seek_connected(supports_lazy, 0, head, tail)
        if num_special >= num_affine
            quote
                $var_out = unroll_applylazy($(Expr(:tuple, (:(pipeline[$i]) for i in op_offset:op_offset+num_lazy-1)...)), $var_in)
                $(augment_impl(var_offset+1, op_offset+num_lazy, after_lazy, avoid_eager))
            end
        else
            quote
                $var_out = unroll_applyaffine($(Expr(:tuple, (:(pipeline[$i]) for i in op_offset:op_offset+num_affine-1)...)), $var_in)
                $(augment_impl(var_offset+1, op_offset+num_affine, after_affine, avoid_eager))
            end
        end
    else
        # At most "head" is lazy (i.e. tail[1] is surely not).
        # Unless "avoid_eager==true" we prefer using "applyeager" in
        # this case because there is no neighbour synergy and we
        # assume "applyeager" is more efficient.
        if !supports_lazy(head) || (!avoid_eager && (length(tail) == 0 || supports_eager(head)))
            quote
                $var_out = applyeager(pipeline[$op_offset], $var_in)
                $(augment_impl(var_offset+1, op_offset+1, tail, avoid_eager))
            end
        else
            quote
                $var_out = applylazy(pipeline[$op_offset], $var_in)
                $(augment_impl(var_offset+1, op_offset+1, tail, avoid_eager))
            end
        end
    end
end

function augment_impl(varname::Symbol, pipeline::NTuple{N,DataType}, args...) where N
    quote
        img_1 = $varname
        $(augment_impl(1, 1, pipeline, args...))
    end
end

# --------------------------------------------------------------------
# The following two methods are just for user inspection and
# debugging purposes as they show what kind of code the pipeline
# generates. They are not called internally by the package itself.
#
# Example:
#
#   julia> Augmentor.augment_impl(Rotate(45) |> Scale(0.9) |> CacheImage() |> FlipX() |> FlipY())
#   quote
#       img_1 = input_image
#       begin
#           img_2 = unroll_applyaffine((pipeline[1], pipeline[2]), img_1)
#           begin
#               img_3 = applyeager(pipeline[3], img_2)
#               begin
#                   img_4 = unroll_applylazy((pipeline[4], pipeline[5]), img_3)
#                   img_4
#               end
#           end
#       end
#   end

function augment_impl(pipeline::AbstractPipeline; avoid_eager = false)
    augment_impl(:input_image, map(typeof, operations(pipeline)), avoid_eager)
end

augment_impl(op::Operation; kw...) = augment_impl((op,); kw...)
