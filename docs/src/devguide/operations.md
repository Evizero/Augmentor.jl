# Adding operations

To implement a new operator, the minimal requirement is to support eager operation:

    decide if this is a generic Operation, ImageOperation or AffineOperation
    (Optional) If the operator requires some runtime generated random parameters to work, then define randparam method
    If the operator is defined element-wise sense, then it's better to define the lazy mode:
        support_lazy(Type{<:MyOp}) = true
        implement applylazy method
    If the operator can't be defined lazily, then must support applyeager method with support_eager(::Type{<:MyOp}) =true

For affine operations, one must implement:

    supports_affineview(::Type{<:MyOp}) = true
    toaffinemap(op::MyOp, img) defines how to generate the affine matrix on input image img
    implement applyaffine

## Supported augment modes

The following tables list all operations and which augment modes they
support.

```@eval
using DelimitedFiles
using Augmentor
import InteractiveUtils: subtypes

function supports(op, mode)
    fn_name = Symbol("supports_" * mode)
    if !isdefined(Augmentor, fn_name)
        fn_name = Symbol(fn_name)
    end

    return @eval Augmentor ($fn_name)($op)
end

emoji(x) = if x "✅" else "❌" end

row(op, supported) = ["`$(string(nameof(op)))`", emoji.(supported)...]

function compose_table(type, modes)
    rows = Array{String}[]

    # Header
    push!(rows, ["name", modes...])
    
    # The abstract type itself
    push!(rows, row(type, supports.(type, modes)))

    for op in subtypes(type)
        # Skip abstract types, they are added in "their" sections (see above)
        if !isabstracttype(op)
            push!(rows, row(op, supports.(op, modes)))
        end
    end

    return permutedims(hcat(rows...))
end

# Parent types of operations
# Adding a type to this list will result in a CSV created
# If you want to display that CSV, you need to add a new @eval block below
types = [Augmentor.Operation,
         Augmentor.AffineOperation,
         Augmentor.ImageOperation,
         Augmentor.ColorOperation]

# Augment modes
modes = ["eager",
         "lazy",
         "permute",
         "view",
         "stepview",
         "affine",
         "affineview"]

for t in types
    writedlm(string(nameof(t)) * ".csv", 
             compose_table(t, modes), ",") end
```

### Operation

```@eval
using DelimitedFiles
using Latexify
mdtable(readdlm("Operation.csv", ',', String, '\n'), latex=false)
```

### AffineOperation

```@eval
using DelimitedFiles
using Latexify
mdtable(readdlm("AffineOperation.csv", ',', String, '\n'), 
        latex=false)
```

### ColorOperation

```@eval
using DelimitedFiles
using Latexify
mdtable(readdlm("ColorOperation.csv", ',', String, '\n'), 
        latex=false)
```

### ImageOperation

```@eval
using DelimitedFiles
using Latexify
mdtable(readdlm("ImageOperation.csv", ',', String, '\n'), 
        latex=false)
```
