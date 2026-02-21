# The PPerm Type

A partial permutation is a partial injective function from ``\{1, 2, \ldots, n\}`` to itself.

## Contents

| Function | Description |
|----------|-------------|
| [`PPerm`](@ref Semigroups.PPerm) | Construct a partial permutation |
| [`degree`](@ref Semigroups.degree) | The degree of the partial permutation |
| [`rank`](@ref Semigroups.rank) | The size of the domain |
| [`images`](@ref Semigroups.images) | The images as a vector |
| [`domain_set`](@ref Semigroups.domain_set) | The domain as a set |
| [`image_set`](@ref Semigroups.image_set) | The image as a set |

## Full API

```@docs
Semigroups.PPerm
```

### Construction

```julia
# Create from domain and range
p = PPerm([1, 2], [3, 4], 5)  # maps 1→3, 2→4, degree 5

# Points not in domain map to UNDEFINED
images(p)  # [3, 4, UNDEFINED, UNDEFINED, UNDEFINED]
```

### Domain and Image

```julia
p = PPerm([1, 3], [2, 4], 4)
domain_set(p)  # Set([1, 3])
image_set(p)   # Set([2, 4])
```

### Inverse

Partial permutations can be inverted:

```julia
p = PPerm([1, 2], [3, 4], 5)
inv(p)  # maps 3→1, 4→2
```
