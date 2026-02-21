# The Perm Type

A permutation is a bijective function from ``\{1, 2, \ldots, n\}`` to itself.

## Contents

| Function | Description |
|----------|-------------|
| [`Perm`](@ref Semigroups.Perm) | Construct a permutation |
| [`degree`](@ref Semigroups.degree) | The degree of the permutation |
| [`images`](@ref Semigroups.images) | The images as a vector |
| `one` | The identity permutation |
| `inv` | The inverse permutation |

## Full API

```@docs
Semigroups.Perm
```

### Construction

```julia
# Create from images (must be a bijection)
p = Perm([2, 3, 1])  # cycle (1 2 3)

# All points must be mapped
degree(p)  # 3
```

### Inverse

Permutations can be inverted:

```julia
p = Perm([2, 3, 1])
inv(p)  # Perm([3, 1, 2])

p * inv(p)  # identity
```

### Cycle Notation

The permutation `Perm([2, 3, 1])` represents the cycle ``(1\ 2\ 3)``, meaning:
- 1 maps to 2
- 2 maps to 3
- 3 maps to 1
