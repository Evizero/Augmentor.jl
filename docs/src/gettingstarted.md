# Getting Started

In this section we will provide a condensed overview of the
package. In order to keep this overview concise, we will not
discuss any background information or theory on the losses here
in detail.

## Installation

To install
[Augmentor.jl](https://github.com/Evizero/Augmentor.jl), start up
Julia and type the following code-snipped into the REPL. It makes
use of the native Julia package manger.

```julia
Pkg.add("Augmentor")
```

Additionally, for example if you encounter any sudden issues, or
in the case you would like to contribute to the package, you can
manually choose to be on the latest (untagged) version.

```julia
Pkg.checkout("Augmentor")
```

## Overview

## Getting Help

To get help on specific functionality you can either look up the
information here, or if you prefer you can make use of Julia's
native doc-system. The following example shows how to get
additional information on [`augment`](@ref) within Julia's REPL:

```julia
?augment
```
