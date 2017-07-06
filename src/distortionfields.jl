# TODO: make work for other dimensions than 2

"""
    uniform_field(gridwidth, gridheight[, scale=0.2, border=true, normalize=true]) -> Array{Float64,3}

Generate a 2D vector field by placing uniformly random generated
displacement vectors on an equally spaced grid of size `gridheight
× gridwidth`.

The resulting array will have 3 dimensions, for which the first
dimension will always have a size of 2, which denotes the y and x
dimension of the vectors.
"""
function uniform_field(gridheight::Int, gridwidth::Int; scale = .2, border = false, normalize = true)
    uniform_field(gridheight, gridwidth, scale, border, normalize)
end

function uniform_field(gridheight::Int, gridwidth::Int, scale, border, normalize)
    A = if !border
        @assert gridwidth > 2 && gridheight > 2
        _2dborder!(safe_rand(2, gridheight, gridwidth), .5)
    else
        @assert gridwidth > 0 && gridheight > 0
        safe_rand(2, gridheight, gridwidth)
    end::Array{Float64,3}
    broadcast!(*, A, A, 2.)
    broadcast!(-, A, A, 1.)
    if normalize
        for d = 1:2
            Ad = view(A, d, :, :)
            broadcast!(*, Ad, Ad, scale / norm(Ad))
        end
    end
    A
end

"""
    gaussian_field(gridwidth, gridheight[, scale=0.2, sigma=2, iterations=1, border=true, normalize=true]) -> Array{Float64,3}

Generate a 2D vector field by placing uniformly random generated
displacement vectors on an equally spaced grid of size
`gridheight × gridwidth`. Additionally, this vector field is
smoothed using a gaussian filter with parameter `sigma`. This
will result in a less chaotic vector field than
[`uniform_field`](@ref) and be much more similar to an elastic
distortion.

The resulting array will have 3 dimensions, for which the first
dimension will always have a size of 2, which denotes the y and x
dimension of the vectors.
"""
function gaussian_field(gridheight::Int, gridwidth::Int; scale = .2, sigma = 2, iterations = 1, border = false, normalize = true)
    gaussian_field(gridheight, gridwidth, scale, sigma, iterations, border, normalize)
end

function gaussian_field(gridheight::Int, gridwidth::Int, scale, sigma, iterations, border, normalize)
    @assert iterations > 0
    A = uniform_field(gridheight, gridwidth, 1., true, false)
    kern = Kernel.gaussian(sigma)
    if !border
        _2dborder!(A, 0.)
        for iter = 1:iterations
            for d = 1:2
                Ad = view(A, d, :, :)
                imfilter!(Ad, Ad, kern)
            end
            _2dborder!(A, 0.)
        end
        A
    else
        for d = 1:2
            Ad = view(A, d, :, :)
            imfilter!(Ad, Ad, kern)
        end
        A
    end
    if normalize
        for d = 1:2
            Ad = view(A, d, :, :)
            broadcast!(*, Ad, Ad, scale / norm(Ad))
        end
    end
    A
end
