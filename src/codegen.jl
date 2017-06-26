"""
    seek_connected(f, N::Int, head::DataType, tail::Tuple) -> (N, seq)

Recursively scan a tuple of `DataType` (split into its `head` and
`tail`) to compute the uninterrupted sequence `seq` of adjacent
operations (and its length `N`) where the predicate `f` is true.
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

function build_pipeline(var_offset::Int, op_offset::Int, pipeline::Tuple)
    build_pipeline(var_offset, op_offset, first(pipeline), Base.tail(pipeline))
end

function build_pipeline(var_offset::Int, op_offset::Int, pipeline::Tuple{})
    :($(Symbol(:img_, var_offset)))
end

function build_pipeline(var_offset::Int, op_offset::Int, head, tail::NTuple{N,DataType}) where N
    var_in  = Symbol(:img_, var_offset)
    var_out = Symbol(:img_, var_offset+1)
    if supports_lazy(head, tail)
        num_affine, rest_affine = uses_affinemap(head, tail) ? seek_connected(uses_affinemap, 0, head, tail) : (0, nothing)
        num_special, _ = seek_connected(x->(supports_permute(x)||supports_view(x)||supports_stepview(x)), 0, head, tail)
        num_lazy, rest_lazy = seek_connected(supports_lazy, 0, head, tail)
        if num_special >= num_affine
            quote
                $var_out = unroll_applylazy($(Expr(:tuple, (:(pipeline[$i]) for i in op_offset:op_offset+num_lazy-1)...)), $var_in)
                $(build_pipeline(var_offset+1, op_offset+num_lazy, rest_lazy))
            end
        else
            quote
                $var_out = unroll_applyaffine($(Expr(:tuple, (:(pipeline[$i]) for i in op_offset:op_offset+num_affine-1)...)), $var_in)
                $(build_pipeline(var_offset+1, op_offset+num_affine, rest_affine))
            end
        end
    else
        if length(tail) == 0 || supports_eager(head) || !supports_lazy(head)
            quote
                $var_out = applyeager(pipeline[$op_offset], $var_in)
                $(build_pipeline(var_offset+1, op_offset+1, tail))
            end
        else # use lazy because there is no special eager implementation
            quote
                $var_out = unroll_applylazy(pipeline[$op_offset], $var_in)
                $(build_pipeline(var_offset+1, op_offset+1, tail))
            end
        end
    end
end

function build_pipeline(varname, pipeline::Tuple)
    quote
        img_1 = $varname
        $(build_pipeline(1, 1, pipeline))
    end
end

# --------------------------------------------------------------------

# The following two methods are just for user inspection and debugging
# purposes as they show what kind of code the pipeline generates.
# They are not called internally by the package itself.
#
# Example:
#
#   julia> Augmentor.build_pipeline(Rotate(45) |> Scale(0.9) |> CacheImage() |> FlipX() |> FlipY())
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

function build_pipeline(pipeline::AbstractPipeline)
    build_pipeline(:input_image, map(typeof, operations(pipeline)))
end

build_pipeline(op::Operation) = build_pipeline((op,))
