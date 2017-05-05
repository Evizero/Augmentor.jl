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

@inline function compile_pipeline(var_offset::Int, tfm_offset::Int, pipeline::Tuple)
    compile_pipeline(var_offset, tfm_offset, first(pipeline), Base.tail(pipeline))
end

@inline function compile_pipeline(var_offset::Int, tfm_offset::Int, pipeline::Tuple{})
    :($(Symbol(:img_, var_offset)))
end

@inline function compile_pipeline(var_offset::Int, tfm_offset::Int, head, tail::Tuple)
    var_in  = Symbol(:img_, var_offset)
    var_out = Symbol(:img_, var_offset+1)
    expr = if islazy(head, tail)
        num_aff, rest = seek_connected_lazy(0, head, tail)
        quote
            $var_out = applylazy($(Expr(:tuple, (:(pipeline[$i]) for i in tfm_offset:tfm_offset+num_aff-1)...)), $var_in)
            $(compile_pipeline(var_offset+1, tfm_offset+num_aff, rest))
        end
    else
        quote
            $var_out = applyeager(pipeline[$tfm_offset], $var_in)
            $(compile_pipeline(var_offset+1, tfm_offset+1, tail))
        end
    end
end

function compile_pipeline(varname, pipeline::Tuple)
    quote
        $(Expr(:meta, :inline))
        img_1 = $varname
        $(compile_pipeline(1, 1, pipeline))
    end
end

# --------------------------------------------------------------------

# just for user inspection to see how it works. not used internally
function inspect_pipeline(pipeline::Pipeline)
    compile_pipeline(:input_image, map(typeof, pipeline))
end

inspect_pipeline(tfm::ImageTransform) = inspect_pipeline((tfm,))
