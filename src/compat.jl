using Pkg

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

# ImageTransformation <= v0.8.3
# PR: https://github.com/JuliaImages/ImageTransformations.jl/pull/89
if Pkg.installed()["ImageTransformations"] <= v"0.8.3"
    Interpolations.tweight(A::AbstractArray{C}) where C<:FixedPoint = C
end
