# [CropNative: Subset image](@id CropNative)

```@docs
CropNative
```

```@eval
include("optable.jl")
@optable "cropn1" => (Rotate(45),Crop(1:210,1:280))
@optable "cropn2" => (Rotate(45),CropNative(1:210,1:280))
tbl = string(
    "`(Rotate(45), Crop(1:210,1:280))` | `(Rotate(45), CropNative(1:210,1:280))`\n",
    "-----|-----\n",
    "![input](../assets/cropn1.png) | ![output](../assets/cropn2.png)\n"
)
Markdown.parse(tbl)
```
