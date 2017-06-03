@compat abstract type Operation end
@compat abstract type ImageOperation <: Operation end
@compat abstract type AffineOperation <: ImageOperation end
@compat abstract type Pipeline end
@compat const AbstractPipeline = Union{Pipeline,Tuple{Vararg{Operation}}}
