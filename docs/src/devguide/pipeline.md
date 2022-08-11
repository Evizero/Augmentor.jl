# Fused pipeline

The secret of Augmentor's performance is the fused pipeline compilation before execution.

<insert some automatically generated table using the script>

## Fused lazy operations

Because many operations are applied in a pointwise sense, Augmentor will detect if we can save intermediate memory allocations by applying it lazily.

<compare `applylazy` and `applyeager` and explain how this saves memory allocation and improve performance>

## Fused Affine operations

Affine operations are internally implemented using `warp` or its lazy version `warpedview`/`invwarpedview`, which are based on 3x3 affine matrix. Thus if there are two or multiple affine operations in a row, we can calculate the result of affine matrix eagerly and fuse them into one. For instance, to apply `pl = Rotate(90) |> Rotate(-90)` to an image, we need to calculate __two__ matrix-vector multiplication for each pixel position, but if we can eagerly fuse them into `pl = Rotate(0)` then we only need to calculate __one__ matrix-vector multiplication, and thus reduces a lot of computations.

<compare `applyeager`, `applylazy` and `applyaffine` and explain how fused affine operations reduces computation>

