@compat abstract type Operation end
@compat abstract type AffineOperation <: Operation end
@compat const Pipeline{N} = NTuple{N,Operation}
