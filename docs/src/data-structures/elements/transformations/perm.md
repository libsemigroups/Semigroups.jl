# The Perm Type

A _permutation_ $f$ is an injective transformation defined on the whole
of $\{1, 2, \ldots, n\}$ for some integer $n$ called the _degree_ of
$f$. A permutation is stored as a vector of the images of
$\{1, 2, \ldots, n\}$, i.e. $((1)f, (2)f, \ldots, (n)f)$.

## Contents

| Function                                                     | Description                         |
| ------------------------------------------------------------ | ----------------------------------- |
| [`Perm`](@ref Semigroups.Perm)                               | Construct a permutation             |
| `p[i]`                                                       | Get the image of a point            |
| [`degree`](@ref Semigroups.degree(::Semigroups.Perm))        | The degree of the permutation       |
| [`rank`](@ref Semigroups.rank(::Semigroups.Perm))            | The number of distinct image values |
| [`image`](@ref Semigroups.image)                             | The sorted set of image values      |
| [`domain`](@ref Semigroups.domain)                           | The sorted set of defined points    |
| [`inverse`](@ref Semigroups.inverse)                         | The inverse permutation             |
| [`one`](@ref Semigroups.one(::Type{Semigroups.Perm}, ::Int)) | The identity permutation            |
| [`copy`](@ref Base.copy(::Semigroups.Perm))                  | Copy a permutation                  |
| [`p * q`](#Composition)                                      | Compose two permutations            |
| [`==`, `<`, `<=`, `>`, `>=`](#Comparison)                    | Comparison operators                |

## Full API

```@docs
Semigroups.Perm
Semigroups.degree(::Semigroups.Perm)
Semigroups.domain(::Semigroups.Perm)
Semigroups.image(::Semigroups.Perm)
Semigroups.inverse(::Semigroups.Perm)
Semigroups.one(::Type{Semigroups.Perm}, ::Int)
Semigroups.rank(::Semigroups.Perm)
```

### Construction

```julia
using Semigroups

# From a vector of images (must be a bijection)
p = Perm([2, 3, 1])  # maps 1->2, 2->3, 3->1
p[1]  # 2

# The degree is inferred from the length
degree(p)  # 3
```

### Inverse

```julia
p = Perm([2, 3, 1])
q = inverse(p)       # Perm([3, 1, 2])
p * inverse(p) == one(Perm, 3)  # true
```

### Composition

Permutations can be composed using `*`:

```julia
p = Perm([2, 3, 1])
q = Perm([3, 1, 2])
r = p * q  # Perm([1, 2, 3]) — the identity
```

### Comparison

Permutations support equality and lexicographic ordering:

```julia
p = Perm([2, 3, 1])
q = copy(p)
p == q  # true
p < Perm([3, 1, 2])  # true
```
