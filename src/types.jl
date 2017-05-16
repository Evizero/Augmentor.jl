@compat abstract type Operation end
@compat abstract type AffineOperation <: Operation end
@compat abstract type Pipeline end
@compat const AbstractPipeline = Union{Pipeline,Tuple{Vararg{Operation}}}
