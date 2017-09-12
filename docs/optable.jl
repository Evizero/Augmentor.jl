# This file is imported by most Augmentor.Operations
# documentation pages. The purpose of this file is to generate
# one or more example images for what the operation does.
# Additionally the result is returned as a markdown table
# showing the input image and the corresponding output image.
#
# Example use for single output image as png:
#
# ```@eval
# include("optable.jl")
# @optable Rotate(15)
# ```
#
# Example use for 8 output images compiled into a gif:
#
# ```@eval
# include("optable.jl")
# @optable 8 => Rotate(-15:15)
# ```

using Augmentor, Images, Colors
using Reel, PaddedViews, OffsetArrays
Reel.set_output_type("gif")

srand(1337)

if !isfile("../assets/testpattern.png")
    pattern = imresize(testpattern(), (240, 320))
    save("../assets/testpattern.png", pattern)
end

pattern = load("../assets/testpattern.png")
pattern_noalpha = ((1 .- alpha.(pattern)) .* colorant"#F3F6F6") .+ (alpha.(pattern) .* color.(pattern))

function drawborder!(img, col)
    img[1:end,   1] .= fill(col, size(img,1))
    img[1:end, end] .= fill(col, size(img,1))
    img[1,   1:end] .= fill(col, size(img,2))
    img[end, 1:end] .= fill(col, size(img,2))
    img
end

centered(img) = OffsetArray(img, convert(Tuple, 1 .- round.(Int, ImageTransformations.center(img))))

macro optable(expr)
    if expr.args[1] == :(=>) && expr.args[2] isa Int
        n = expr.args[2]
        nexpr = expr.args[3]
        name = string(nexpr.args[1])
        descr = string(nexpr)
        :(optable($(esc(nexpr)), $name, $descr, $n))
    elseif expr.args[1] == :(=>) && expr.args[2] isa String
        name = expr.args[2]
        nexpr = expr.args[3]
        descr = string(nexpr)
        :(optable($(esc(nexpr)), $name, $descr))
    else
        name = string(expr.args[1])
        descr = string(expr)
        :(optable($(esc(expr)), $name, $descr))
    end
end

function optable(op, name, descr)
    fname = joinpath("..", "assets", string(name, ".png"))
    i = 2
    while isfile(fname)
        fname = joinpath("..", "assets", string(name, i, ".png"))
        i = i + 1
    end
    out = augment(pattern, op)
    save(fname, out)
    header = length(descr) < 20 ? "Output for `$descr`" : "`$descr`"
    tbl = string(
        "Input | $header\n",
        "------|--------\n",
        "![input](../assets/testpattern.png) | ![output]($fname)\n"
    )
    Markdown.parse(tbl)
end

function optable(op, name, descr, n)
    fname = joinpath("..", "assets", string(name, ".gif"))
    i = 2
    while isfile(fname)
        fname = joinpath("..", "assets", string(name, i, ".gif"))
        i = i + 1
    end
    raw_imgs = [centered(drawborder!(augment(pattern_noalpha, op), colorant"pink")) for i in 1:n]
    imgs = map(parent, map(copy, [paddedviews(colorant"#F3F6F6", raw_imgs...)...]))
    insert!(imgs, 1, first(imgs)) # otherwise loop isn't smooth
    film = roll(imgs, fps = 2)
    write(fname, film)
    header = length(descr) < 20 ? "Samples for `$descr`" : "`$descr`"
    tbl = string(
        "Input | $header\n",
        "------|--------\n",
        "![input](../assets/testpattern.png) | ![output]($fname)\n"
    )
    Markdown.parse(tbl)
end
