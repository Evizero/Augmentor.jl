@inline function seek_connected_lazy(N, head, tail::Tuple)
    if islazy(head)
        seek_connected_lazy(N+1, first(tail), Base.tail(tail))
    else
        N, (head, tail...)
    end
end

@inline function seek_connected_lazy(N, head, tail::Tuple{})
    if islazy(head)
        N+1, ()
    else
        N, (head,)
    end
end

# --------------------------------------------------------------------

@inline islazy(head, tail::Tuple) = islazy(head) && islazy(first(tail))
@inline islazy(head, tail::Tuple{}) = false

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
    expr = if islazy(head, tail)
        num_lazy, rest = seek_connected_lazy(0, head, tail)
        quote
            $var_out = applylazy($(Expr(:tuple, (:(pipeline[$i]) for i in op_offset:op_offset+num_lazy-1)...)), $var_in)
            $(build_pipeline(var_offset+1, op_offset+num_lazy, rest))
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
