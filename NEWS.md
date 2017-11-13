# v0.3.1

Small fixes:

- Update some internals to comply with upstream changes to
  ImageCore (v0.5.0) and ColorTypes (v0.6.6).

# v0.3.0

New functionality:

- `augmentbatch!`: Now accepts an `ObsDimension` as an optional
  last parameter.

Other changes:

- Add basic `PkgBenchmark` integration.

- Switch testing backend for reference tests to
  [ReferenceTests.jl](https://github.com/Evizero/ReferenceTests.jl).

Online documentation:

- Switch documentation engine to
  [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl)

- Add detailed documentation for provided operations.

- Add basic usage examples/tutorials

- Slight improvements to the README

# v0.2.0

New functionality:

- `augment!`: Use preallocated storage for the output

- `augmentbatch!`: Augment a whole batch of images. Optionally
  using multiple threads.

New operations:

- `ConvertEltype`: Convert the array elements to the given type

Other changes:

- `Either` can now lazily combine affine operations with operations
  such as `Crop`, `Zoom`, and `Resize`. This is because a new kind
  of support was introduced called `Augmentor.supports_affineview`,
  which is true if an operation can represent itself as a `SubArray`
  of a `InvWarpedView`.

- Dropped 0.5 support

# v0.1.0

New operations:

- `CropRatio`: Crop to the specified aspect ratio around the center.

- `RCropRatio`: Crop random window with the specified aspect ratio.

- `SplitChannels`: Separate the color channels into a dedicated array dimension.

- `CombineChannels`: Collapse the first dimension into a specific colorant.

- `PermuteDims`: Reorganize the array dimensions into a specific order.

- `Reshape`: Change or reinterpret the shape of the array.
