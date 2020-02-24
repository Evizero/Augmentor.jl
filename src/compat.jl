if VERSION >= v"1.3"
    const safe_rand = rand
else
    # rand is thread safe after julia 1.3
    # TODO: delete this when we decide to drop 1.0 compatibility

    # --------------------------------------------------------------------
    # rand() is not threadsafe (https://discourse.julialang.org/t/4683)

    # Because we only require random numbers to sample parameters
    # and not the actual expensive computation, this seems like a better
    # approach than using separate RNG per thread.
    const rand_mutex = Ref{Threads.Mutex}()

    # constant overhead of about 80 ns compared to unsafe rand
    function safe_rand(args...)
        lock(rand_mutex[])
        result = rand(args...)
        unlock(rand_mutex[])
        result
    end
end

# issue #39
if all(map((FixedPoint, Normed)) do T
        isempty(methodswith(AbstractArray{<:T}, Interpolations.tweight))
    end)
    # Reached when upstream package (e.g., FixedPoint) doesn't provide a specialization
    Interpolations.tweight(A::AbstractArray{T}) where T<:FixedPoint = T
end

# backward support for OffsetArrays v0
if isdefined(OffsetArrays, :IdOffsetRange)
    # introduced by OffsetArrays v1.0.0
    OffsetRange = Union{UnitRange, IdentityUnitRange, OffsetArrays.IdOffsetRange}
else
    OffsetRange = Union{UnitRange, IdentityUnitRange}
end
