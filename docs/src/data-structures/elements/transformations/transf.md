# The Transf Type

A transformation is a function from ``\{1, 2, \ldots, n\}`` to itself.

## Contents

| Function | Description |
|----------|-------------|
| [`Transf`](@ref Semigroups.Transf) | Construct a transformation |
| [`degree`](@ref Semigroups.degree) | The degree of the transformation |
| [`rank`](@ref Semigroups.rank) | The number of distinct image points |
| [`images`](@ref Semigroups.images) | The images as a vector |
| `one` | The identity transformation |

## Full API

```@docs
Semigroups.Transf
```

### Construction

```julia
# Create a transformation from images (1-based indexing)
t = Transf([2, 3, 1, 4])  # maps 1→2, 2→3, 3→1, 4→4

# The degree is inferred from the length
degree(t)  # 4
```

### Indexing

Transformations support indexing to get individual images:

```julia
t = Transf([2, 3, 1])
t[1]  # 2
t[2]  # 3
t[3]  # 1
```

### Composition

Transformations can be composed using `*`:

```julia
s = Transf([2, 1, 3])
t = Transf([3, 2, 1])
s * t  # apply s first, then t
```
