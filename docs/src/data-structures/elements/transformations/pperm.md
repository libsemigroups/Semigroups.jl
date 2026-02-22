# The PPerm Type

A _partial permutation_ $f$ is an injective partial transformation,
which is stored as the vector of images of $\{1,2,\ldots,n\}$,
i.e. $((1)f,(2)f,\ldots,(n)f)$ where the value
[`UNDEFINED`](@ref Semigroups.UNDEFINED) is used to indicate that
$(i)f$ is undefined (i.e. not among the points where $f$ is defined).

## Contents

| Function                                                | Description                                                                                      |
| ------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| [`PPerm`](@ref Semigroups.PPerm)                        | Construct a partial permutation                                                                  |
| `p[i]`                                                  | Get the image of a point (returns [`UNDEFINED`](@ref Semigroups.UNDEFINED) if not in the domain) |
| [`degree`](@ref Semigroups.degree(::Semigroups.PPerm))  | The degree of the partial permutation                                                            |
| [`rank`](@ref Semigroups.rank)                          | The number of distinct image values, not including `UNDEFINED`                                   |
| [`image`](@ref Semigroups.image)                        | The sorted set of image values                                                                   |
| [`domain`](@ref Semigroups.domain)                      | The sorted set of points where `f` is defined                                                    |
| [`inverse`](@ref inverse(::Semigroups.PPerm))           | The inverse partial permutation                                                                  |
| [`left_one`](@ref Semigroups.left_one)                  | The identity on the domain                                                                       |
| [`one`](@ref Semigroups.one(::Semigroups.PPerm, ::Int)) | The identity partial permutation of the same degree                                              |
| [`right_one`](@ref Semigroups.right_one)                | The identity on the image                                                                        |
| [`copy`](@ref Base.copy(::Semigroups.PPerm))            | Copy a partial permutation                                                                       |
| [`p * q`](#Composition)                                 | Compose two partial permutations                                                                 |
| [`==`, `<`, `<=`, `>`, `>=`](#Comparison)               | Comparison operators                                                                             |

## Full API

```@docs
Semigroups.PPerm
Semigroups.degree(::Semigroups.PPerm)
Semigroups.domain(::Semigroups.PPerm)
Semigroups.image(::Semigroups.PPerm)
Semigroups.inverse(::Semigroups.PPerm)
Semigroups.left_one(::Semigroups.PPerm)
Semigroups.one(::Semigroups.PPerm)
Semigroups.one(::Type{Semigroups.PPerm}, ::Int)
Semigroups.right_one(::Semigroups.PPerm)
Semigroups.rank(::Semigroups.PPerm)
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

### Composition

Partial permutations can be composed using `*`:

```julia
p = PPerm([1, 2], [3, 4], 5)
q = PPerm([3, 4], [5, 1], 5)
r = p * q  # 1 -> 5, 2 -> 1
```

### Comparison

Partial permutations support equality and lexicographic ordering:

```julia
p = PPerm([1, 2], [3, 4], 5)
q = copy(p)
p == q  # true
p < PPerm([1, 2], [4, 3], 5)  # true
```
