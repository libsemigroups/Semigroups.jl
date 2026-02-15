# The PPerm Type

A *partial permutation* ``f`` is just an injective partial transformation,
which is stored as a vector of the images of ``\{1, 2, \ldots, n\}``,
i.e. ``((1)f, (2)f, \ldots, (n)f)`` where the value [`UNDEFINED`](@ref
Semigroups.UNDEFINED) is used to indicate that ``(i)f`` is undefined
(i.e. not among the points where ``f`` is defined).

## Contents

| Function | Description |
|----------|-------------|
| [`PPerm`](@ref Semigroups.PPerm) | Construct a partial permutation |
| `p[i]` | Get the image of a point (returns [`UNDEFINED`](@ref Semigroups.UNDEFINED) if not in the domain) |
| [`degree`](@ref Semigroups.degree) | The degree of the partial permutation |
| [`rank`](@ref Semigroups.rank) | The number of distinct image values, not including `UNDEFINED` |
| [`domain_set`](@ref Semigroups.domain_set) | The domain as a sorted vector |
| [`image_set`](@ref Semigroups.image_set) | The image as a sorted vector |
| [`inv`](@ref Base.inv(::Semigroups.PPerm)) | The inverse partial permutation |
| [`left_one`](@ref Semigroups.left_one) | The identity on the domain |
| [`right_one`](@ref Semigroups.right_one) | The identity on the image |
| [`one`](@ref Base.one(::Semigroups.PPerm)) | The identity partial permutation of the same degree |
| [`copy`](@ref Base.copy(::Semigroups.PPerm)) | Copy a partial permutation |

## Full API

```@docs
Semigroups.PPerm
Base.inv(::Semigroups.PPerm)
Base.one(::Semigroups.PPerm)
Base.copy(::Semigroups.PPerm)
```

### Construction

```julia
using Semigroups

# From a vector of images (use UNDEFINED for undefined points)
p = PPerm([3, 4, UNDEFINED, UNDEFINED, UNDEFINED])
p[1]  # 3
p[3]  # UNDEFINED

# From domain, range, and degree
p = PPerm([1, 2], [3, 4], 5)  # 1 -> 3, 2 -> 4, degree 5
```

### Domain and Image

```julia
p = PPerm([1, 3], [2, 4], 4)
domain_set(p)  # [1, 3]
image_set(p)   # [2, 4]
```

### Inverse

```julia
p = PPerm([1, 2], [3, 4], 5)
q = inv(p)           # maps 3 -> 1, 4 -> 2
p * inv(p) == left_one(p)   # true
inv(p) * p == right_one(p)  # true
```

### Left and Right Ones

```julia
p = PPerm([1, 3], [2, 4], 4)
left_one(p) * p == p   # true
p * right_one(p) == p  # true
```
