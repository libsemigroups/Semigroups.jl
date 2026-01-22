# Transf, PPerm, and Perm Helpers

This page contains the documentation for helper functions that work with transformations, partial permutations, and permutations.

## Contents

| Function | Description |
|----------|-------------|
| [`degree`](@ref Semigroups.degree) | The degree of an element |
| [`rank`](@ref Semigroups.rank) | The rank (number of image points) |
| [`images`](@ref Semigroups.images) | Get image vector |
| [`image_set`](@ref Semigroups.image_set) | Get image as a set |
| [`domain_set`](@ref Semigroups.domain_set) | Get domain as a set |
| [`left_one`](@ref Semigroups.left_one) | Left identity element |
| [`right_one`](@ref Semigroups.right_one) | Right identity element |

## Full API

```@docs
Semigroups.degree
Semigroups.rank
Semigroups.images
Semigroups.image_set
Semigroups.domain_set
Semigroups.left_one
Semigroups.right_one
```

## Examples

### Degree and Rank

```julia
t = Transf([2, 2, 3])
degree(t)  # 3 (size of the domain)
rank(t)    # 2 (number of distinct image points: {2, 3})
```

### Identity Elements

```julia
t = Transf([2, 3, 1, 4])

# Left identity: e * t == t
e = left_one(t)   # identity transformation of same degree

# Right identity: t * e == t
r = right_one(t)  # identity on image set
```
