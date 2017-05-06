@inline function seek_connected(f, N, head, tail::Tuple)
    if f(head)
        seek_connected(f, N+1, first(tail), Base.tail(tail))
    else
        N, (head, tail...)
    end
end

@inline function seek_connected(f, N, head, tail::Tuple{})
    if f(head)
        N+1, ()
    else
        N, (head,)
    end
end

# --------------------------------------------------------------------

@inline supports_lazy(head, tail::Tuple) = supports_lazy(head) && supports_lazy(first(tail))
@inline supports_lazy(head, tail::Tuple{}) = false
@inline supports_affine(head, tail::Tuple) = supports_affine(head) && supports_affine(first(tail))
@inline supports_affine(head, tail::Tuple{}) = false

# --------------------------------------------------------------------

@inline function build_pipeline(var_offset::Int, op_offset::Int, pipeline::Tuple)
    build_pipeline(var_offset, op_offset, first(pipeline), Base.tail(pipeline))
end

@inline function build_pipeline(var_offset::Int, op_offset::Int, pipeline::Tuple{})
    :($(Symbol(:img_, var_offset)))
end

@inline function build_pipeline(var_offset::Int, op_offset::Int, head, tail::Tuple)
    var_in  = Symbol(:img_, var_offset)
    var_out = Symbol(:img_, var_offset+1)
    if supports_lazy(head, tail)
        num_affine, rest_affine = supports_affine(head, tail) ? seek_connected(supports_affine, 0, head, tail) : (0, nothing)
        num_lazy, rest_lazy = seek_connected(x->(supports_permute(x)||supports_stepview(x)), 0, head, tail)
        if num_lazy >= num_affine
            quote
                $var_out = applylazy($(Expr(:tuple, (:(pipeline[$i]) for i in op_offset:op_offset+num_lazy-1)...)), $var_in)
                $(build_pipeline(var_offset+1, op_offset+num_lazy, rest_lazy))
            end
        else
            quote
                $var_out = applyaffine($(Expr(:tuple, (:(pipeline[$i]) for i in op_offset:op_offset+num_affine-1)...)), $var_in)
                $(build_pipeline(var_offset+1, op_offset+num_affine, rest_affine))
            end
        end
    else
        quote
            $var_out = applyeager(pipeline[$op_offset], $var_in)
            $(build_pipeline(var_offset+1, op_offset+1, tail))
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

# just for user inspection to see how it works. not used internally
function build_pipeline(pipeline::Pipeline)
    build_pipeline(:input_image, map(typeof, pipeline))
end

build_pipeline(op::Operation) = build_pipeline((op,))
